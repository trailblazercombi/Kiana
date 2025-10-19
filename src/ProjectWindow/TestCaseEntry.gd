class_name TestCaseEntry extends MarginContainer

func set_data(
	ze_selected: bool, 
	the_name: StringName,
	the_desc: StringName
) -> void:
	%TestCaseSelected.button_pressed = ze_selected
	%TestCaseName.text = the_name
	%TestCaseDescription.text = the_desc

func selected() -> bool:
	return %TestCaseSelected.button_pressed
