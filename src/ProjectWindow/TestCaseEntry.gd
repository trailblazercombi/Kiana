class_name TestCaseEntry extends MarginContainer

signal selected(toggled_on: bool)

var test_case_file_path: StringName
var test_case: TestCase

func _ready() -> void:
	%TestCaseSelected.toggled.connect(func(yeah: bool) -> void:
		selected.emit(yeah)
		if yeah: Global.selected_test_cases.append(test_case)
		else: Global.selected_test_cases.erase(test_case)
	)
	
	%TestCaseSelected.button_pressed = Global.selected_test_cases.has(test_case)

	%TestCaseName.text = test_case.title
	%TestCaseDescription.text = test_case.description
	
	%TestCaseEdit.button_down.connect(func() -> void:
		Global.edit_test_case(test_case.file_name)
	)
	
	%TestCaseDelete.button_down.connect(func() -> void:
		test_case.move_to_trash()
	)
	
	%TestCaseResults.button_down.connect(func() -> void:
		Global.selected_test_cases.clear()
		Global.selected_test_cases.push_front(test_case)
		get_tree().change_scene_to_file("res://src/TestCaseResultViewer/TestCaseResultViewer.tscn")
	)
