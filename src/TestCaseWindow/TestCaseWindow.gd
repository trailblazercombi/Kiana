class_name TestCaseWindow extends MarginContainer

var result: TestResult

var step_now: int = 0:
	set(value):
		step_now = value
		var step_count: int = result.kiana_file[&"test_steps"].size()
		var the_step: Dictionary = result.kiana_file[&"test_steps"][step_now]
		
		%Previous.disabled = step_now < 1
		%Next.disabled = not step_now < step_count - 1
		
		%StepNum.text = tr(&"Step %d out of %d") % [step_now + 1, step_count]
		%StepAction.text = the_step[&"step_action"]
		%StepExpect.text = the_step[&"step_expect"]
		%StepActual.text = the_step[&"step_actual"]
		
		match the_step[&"step_status"]:
			TestResult.StepStatus.PASSED: %StepPass.button_pressed = true
			TestResult.StepStatus.FAILED: %StepFail.button_pressed = true
			
			TestResult.StepStatus.NOT_EVALUATED:
				%StepNotEval.button_pressed = true

func _ready() -> void:
	var case: TestCase = Global.selected_test_cases.pop_front()
	if case == null:
		Global.show_throbber(tr(&"Error..."))
		Global.popup_error(
			tr(&"No Test Case selected!"), func() -> void:
				get_tree().change_scene_to_file(
					"res://src/ProjectWindow/ProjectWindow.tscn"
				)
		)
		return
	
	var cases_left: int = Global.selected_test_cases.size()
	
	if cases_left > 0:
		%TestCase.text = &"%s (%d cases left)" % [case.title, cases_left]
		%NextCase.disabled = false
	else:
		%TestCase.text = case.title
		%NextCase.disabled = true
	
	result = TestResult.new(case.file_name)
	
	%EndTesting.button_down.connect(func() -> void:
		result.save_to_disk()
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%NextCase.button_down.connect(func() -> void:
		result.save_to_disk()
		get_tree().change_scene_to_file("res://src/TestCaseWindow/TestCaseWindow.tscn")
	)
	
	%Previous.button_down.connect(func() -> void: step_now -= 1)
	%Next.button_down.connect(func() -> void: step_now += 1)
	
	%StepActual.text_changed.connect(func() -> void:
		result.kiana_file[&"test_steps"][step_now][&"step_actual"] = %StepActual.text
	)
	
	%StepNotEval.button_down.connect(func() -> void: 
		eval_step(TestResult.StepStatus.NOT_EVALUATED)
	)
	
	%StepFail.button_down.connect(func() -> void:
		eval_step(TestResult.StepStatus.FAILED)
	)
	
	%StepPass.button_down.connect(func() -> void:
		eval_step(TestResult.StepStatus.PASSED)
	)
	
	var pascal: PackedScene = preload("res://src/TestCaseWindow/TestStepResult.tscn")
	for i in range(result.test_steps.size()):
		var inst: TestStepResult = pascal.instantiate()
		inst.color = TestStepResult.NO_EVAL
		inst.step_number = &"%s" % (i + 1)
		%ProgressBar.add_child(inst)
	
	step_now = 0

func eval_step(eval: TestResult.StepStatus) -> void:
	result.test_steps[step_now][&"step_status"] = eval
	match eval:
		TestResult.StepStatus.NOT_EVALUATED:
			%ProgressBar.get_child(step_now).color = TestStepResult.NO_EVAL
		TestResult.StepStatus.PASSED:
			%ProgressBar.get_child(step_now).color = TestStepResult.PASS
		TestResult.StepStatus.FAILED:
			%ProgressBar.get_child(step_now).color = TestStepResult.FAIL
