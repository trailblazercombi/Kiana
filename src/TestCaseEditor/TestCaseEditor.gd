class_name TestCaseEditor extends MarginContainer

var preload_tse: PackedScene = preload("res://src/TestCaseEditor/TestStepEntry.tscn")

var test_case: TestCase

func _ready() -> void:
	test_case = TestCase.new(Global.last_known_test_case_edit_path)
	
	%TestCaseName.text = test_case.title
	%TestCaseDescription.text = test_case.description
	
	%TestCaseName.text_changed.connect(func(text: String) -> void:
		test_case.title = text
	)
	
	%TestCaseDescription.text_changed.connect(func() -> void:
		test_case.description = %TestCaseDescription.text
	)
	
	for test_step: Dictionary in test_case.get_all_steps():
		var entry: TestStepEntry = preload_tse.instantiate()
		entry.step = test_step
		%TestSteps.add_child(entry)
	
	%AddStep.button_down.connect(func() -> void:
		Global.show_throbber(&"Creating step...")
		var new_step: TestStepEntry = preload_tse.instantiate()
		
		new_step.move_up.connect(func() -> void:
			%TestSteps.move_child(new_step, new_step.get_index() - 1)
		)
		
		new_step.move_down.connect(func() -> void:
			%TestSteps.move_child(new_step, new_step.get_index() + 1)
		)
		
		new_step.edit.connect(func() -> void:
			Global.show_throbber(&"Editing step...")
			$StepCreateWindow.edit_step(new_step)
		)
		
		new_step.delete.connect(func() -> void:
			%TestSteps.remove_child(new_step)
			new_step.queue_free()
		)
		
		%TestSteps.add_child(
			await $StepCreateWindow.edit_step(new_step)
		)
	)
	
	$StepCreateWindow.done.connect(func() -> void:
		Global.hide_throbber()
		$StepCreateWindow.hide()
	)
	
	%Cancel.button_down.connect(func() -> void:
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%Save.button_down.connect(func() -> void:
		test_case.test_steps = _compile_steps()
		test_case.save_to_disk()
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)

func _compile_steps() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for child: TestStepEntry in %TestSteps.get_children():
		result.append(child.step)
	return result
