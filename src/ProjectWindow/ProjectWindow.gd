class_name ProjectWindow extends MarginContainer

func _ready() -> void:
	%ProjectName.text = Global.project.title
	%ProjectDescription.text = Global.project.description
	
	%CloseProject.button_down.connect(func() -> void:
		get_tree().change_scene_to_file("res://src/ProjectSelect/ProjectSelect.tscn")
	)
	
	%Credentials.button_down.connect(func() -> void:
		Global.edit_credentials()
	)
	
	%ProjectName.text_changed.connect(func(text: String) -> void:
		Global.project.title = text
	)
	
	%ProjectDescription.text_changed.connect(func() -> void:
		Global.project.description = %ProjectDescription.text
	)
	
	for test_case: TestCase in Global.project.get_test_cases():
		%TestCaseList.add_child(null)
