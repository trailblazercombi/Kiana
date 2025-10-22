class_name ProjectWindow extends MarginContainer

var preload_tce: PackedScene = preload("res://src/ProjectWindow/TestCaseEntry.tscn")

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
	
	%TestCaseAdd.button_down.connect(func() -> void:
		Global.edit_test_case(&"")
	)
	
	%TestCaseBegin.button_down.connect(func() -> void:
		get_tree().change_scene_to_file("res://src/TestCaseWindow/TestCaseWindow.tscn")
	)
	
	Global.refresh_data.connect(collect_test_cases)
	collect_test_cases()

func collect_test_cases() -> void:
	for child in %TestCaseList.get_children():
		child.queue_free()
	for test_case: TestCase in Global.project.get_test_cases():
		var tce: TestCaseEntry = preload_tce.instantiate()
		tce.test_case = test_case
		%TestCaseList.add_child(tce)
