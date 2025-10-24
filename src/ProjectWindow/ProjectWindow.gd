class_name ProjectWindow extends Container

var preload_tce: PackedScene = preload("res://src/ProjectWindow/TestCaseEntry.tscn")

func _ready() -> void:
	%ProjectName.text = Global.project.title
	%ProjectDescription.text = Global.project.description
	
	if Global.project.tab_at_open == Project.Tab.TESTS:
		%TabCheck.button_pressed = true
		$ContentTabs/Tests.show()
	
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
	
	%TabCheck.toggled.connect(func(yeah: bool) -> void:
		Global.project.tab_at_open = Project.Tab.TESTS if yeah else Project.Tab.PROJECT
		Global.project.save_to_disk()
	)
	
	Global.refresh_data.connect(collect_test_cases)
	collect_test_cases()
	
	Global.selected_test_cases.clear()

func collect_test_cases() -> void:
	Global.show_throbber(&"Working...")
	for child in %TestCaseList.get_children():
		child.queue_free()
	for test_case: TestCase in Global.project.get_test_cases():
		var tce: TestCaseEntry = preload_tce.instantiate()
		tce.test_case = test_case
		%TestCaseList.add_child(tce)
	Global.hide_throbber()
