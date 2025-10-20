class_name TestCaseEditor extends MarginContainer

var ticked_steps: Array[TestStep] = []

var test_case: TestCase:
	set(value):
		test_case = value
		if value: %Save.disabled = false
		else: %Save.disabled = true

func _ready() -> void:
	if Global.test_cases_ticked.is_empty(): test_case = null
	else: test_case = Global.test_cases_ticked.front()
	
	%AddStep.button_down.connect(func() -> void:
		$StepCreateWindow.popup()
	)
	
	%Cancel.button_down.connect(func() -> void:
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%Save.button_down.connect(func() -> void:
		Global.test_cases_ticked.clear()
		Global.open_project.test_cases.append(test_case)
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%TestSteps.child_entered_tree.connect(maybe_enable_save_button)
	%TestCaseName.text_changed.connect(maybe_enable_save_button)

func maybe_enable_save_button() -> void:
	%Save.disabled = (
		%TestSteps.get_children().is_empty()
		or %TestCaseName.text.is_empty()
	)
