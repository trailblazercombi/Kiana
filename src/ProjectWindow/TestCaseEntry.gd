class_name TestCaseEntry extends MarginContainer

signal selected(toggled_on: bool)

var test_case_file_path: StringName
var test_case: TestCase

func _ready() -> void:
	%TestCaseSelected.toggled.connect(selected.emit)

	%TestCaseName.text = test_case.title
	%TestCaseDescription.text = test_case.description
	
	%TestCaseEdit.button_down.connect(func() -> void:
		Global.edit_test_case(test_case.file_name)
	)
	
	%TestCaseDelete.button_down.connect(func() -> void:
		test_case.move_to_trash()
	)
