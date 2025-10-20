class_name TestCaseEntry extends MarginContainer

var case: TestCase:
	set(value):
		case = value
		if value != null:
			%TestCaseSelected.button_pressed = false
			%TestCaseName.text = case.test_case_name
			%TestCaseDescription.text = case.test_case_description

func selected() -> bool:
	return %TestCaseSelected.button_pressed
