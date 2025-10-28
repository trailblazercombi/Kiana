class_name TestCaseEditor extends MarginContainer

var preload_tse: PackedScene = preload("res://src/TestCaseEditor/TestStepEntry.tscn")

var test_case: TestCase

func _ready() -> void:
	hide()
	Global.show_throbber(tr(&"Working..."))
	
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
		connect_signals(entry)
	
	disable_nonsense_move_commands()
	
	%AddStep.button_down.connect(func() -> void:
		Global.show_throbber(&"Creating step...")
		var new_step: TestStepEntry = preload_tse.instantiate()
		connect_signals(new_step)
		
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
		if test_case.save_to_disk():
			get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	Global.hide_throbber()
	show()

func _compile_steps() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for child: Node in %TestSteps.get_children():
		if child is TestStepEntry: result.append(child.step)
	return result

func disable_nonsense_move_commands() -> void:
	for entry: Node in %TestSteps.get_children():
		if entry is TestCaseEntry:
			entry.enable_up()
			entry.enable_down()
			
			if entry.get_index() == 0: 
				entry.disable_up()
			if entry.get_index() == %TestSteps.get_child_count() - 1: 
				entry.disable_down()

func connect_signals(entry: TestStepEntry) -> void:
	entry.move_up.connect(func() -> void:
		%TestSteps.move_child(entry, entry.get_index() - 1)
		disable_nonsense_move_commands()
	)
	
	entry.move_down.connect(func() -> void:
		%TestSteps.move_child(entry, entry.get_index() + 1)
		disable_nonsense_move_commands()
	)
	
	entry.edit.connect(func() -> void:
		Global.show_throbber(&"Editing step...")
		$StepCreateWindow.edit_step(entry)
		disable_nonsense_move_commands()
	)
	
	entry.delete.connect(func() -> void:
		%TestSteps.remove_child(entry)
		entry.queue_free()
		disable_nonsense_move_commands()
	)
