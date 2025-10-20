class_name TestCaseWindow extends MarginContainer

var test_case_queue: Array[TestCase] = []

var current_test: TestResult
var current_step: TestStep

var time_elapsed: float = 0
var time_counting: bool = false

func _process(delta: float) -> void:
	if time_counting:
		time_elapsed = time_elapsed + delta
		var time_int: int = int(time_elapsed)
		
		@warning_ignore("integer_division")
		%TimeElapsed.text = tr(&"%s elapsed") % (tr(&"%02d:%02d:%02d") % [ \
			time_int / 3600, (time_int % 3600) / 60, time_int % 60])

func _ready() -> void:
	%TesterName.text = tr(&"Tester: %s") % Global.credentials
	
	%EndTesting.disabled = true
	%NextCase.disabled = true
	%StepActual.editable = false
	%StepFail.disabled = true
	%StepPass.disabled = true
	%Previous.disabled = true
	%Next.disabled = true
	
	%EndTesting.button_down.connect(func() -> void:
		%AutoAdvance.disabled = true
		end_test()
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%NextCase.button_down.connect(func() -> void:
		end_test()
		start_test(test_case_queue.pop_front())
	)
	
	%StepActual.text_changed.connect(func() -> void:
		(current_test.step_results.get(current_step)
			as StepResult).actual_result_text = %StepActual.text
	)
	
	%StepFail.button_down.connect(func() -> void:
		(current_test.step_results.get(current_step)
			as StepResult).do_fail()
		%StepFail.disabled = true
		%StepPass.disabled = false
		if (
			%AutoAdvance.button_pressed 
			and current_test.case.has_next_step(current_step)
		):
			stop_step()
			start_step(current_test.next_step(current_step).front())
	)
	
	%StepPass.button_down.connect(func() -> void:
		(current_test.step_results.get(current_step)
			as StepResult).do_pass()
		%StepPass.disabled = true
		%StepFail.disabled = false
		
		if %StepActual.text == &"":
			%StepActual.text = %StepExpect.text
			%StepActual.text_changed.emit()
		
		if (
			%AutoAdvance.button_pressed 
			and current_test.case.has_next_step(current_step)
		):
			stop_step()
			start_step(current_test.next_step(current_step).front())
	)
	
	%Previous.button_down.connect(func() -> void:
		stop_step()
		start_step(current_test.previous_step(current_step).front())
		%AutoAdvance.button_pressed = false
	)
	
	%Next.button_down.connect(func() -> void:
		stop_step()
		start_step(current_test.next_step(current_step).front())
		%AutoAdvance.button_pressed = false
	)
	
	start_test(test_case_queue.pop_front())

func start_test(case: TestCase) -> void:
	if case == null: return
	if current_test != null: return
	
	current_test = TestResult.new(case)
	%TestCase.text = tr(&"Test Case: %s") % case.test_case_name
	if not test_case_queue.is_empty():
		%TestCase.text = tr(&"%s (%d cases left)") % [
			%TestCase.text, test_case_queue.size()
		]
	%TimeElapsed.text = tr(&"%s elapsed") % &"00:00"
	
	for step: StepResult in current_test.step_results.values():
		%ProgressBar.add_child(step)
	
	%StepNum.text = tr(&"Step %d of %d") % [1, current_test.step_results.size()]
	
	%EndTesting.disabled = false
	%NextCase.disabled = test_case_queue.is_empty()
	
	start_step(current_test.next_step(null).front())

func end_test() -> void:
	if current_test == null: return
	
	%EndTesting.disabled = true
	%NextCase.disabled = true
	%StepActual.editable = false
	%StepFail.disabled = true
	%StepPass.disabled = true
	%Previous.disabled = true
	%Next.disabled = true
	
	%TestCase.text = tr(&"No Test Case Loaded")
	%TimeElapsed.text = &""
	
	%StepAction.text = &""
	%StepExpect.text = &""
	%StepActual.text = &""
	
	for child: Node in %ProgressBar.get_children():
		%ProgressBar.remove_child(child)
	
	Global.open_project.test_results.set(
		current_test.case,
		current_test
	)
	
	time_counting = false
	time_elapsed = 0
	
	current_test = null

func start_step(step: TestStep) -> void:
	current_step = step
	%StepAction.text = current_step.action
	%StepExpect.text = current_step.expected_result
	%StepActual.text = (
		current_test.step_results.get(current_step) as StepResult
	).actual_result_text
	%StepActual.editable = true
	
	%Previous.disabled = not current_test.case.has_previous_step(step)
	%Next.disabled = not current_test.case.has_next_step(step)
	%StepNum.text = tr(&"Step %d of %d") % [
		current_test.case.current_step_num(step) + 1, 
		current_test.step_results.size()
	]
	
	%StepFail.disabled = (
		current_test.step_results.get(current_step) as StepResult
	).is_failed()
	
	%StepPass.disabled = (
		current_test.step_results.get(current_step) as StepResult
	).is_passed()
	
	time_counting = true

func stop_step() -> void:
	time_counting = false
	%StepActual.editable = false
	%StepFail.disabled = true
	%StepPass.disabled = true
	%Previous.disabled = true
	%Next.disabled = true
