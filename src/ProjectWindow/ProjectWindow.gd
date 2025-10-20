class_name ProjectWindow extends MarginContainer

func _ready() -> void:
	var ptce: PackedScene = preload("res://src/ProjectWindow/TestCaseEntry.tscn")
	for case: TestCase in Global.open_project.test_cases:
		var tcen: TestCaseEntry = ptce.instantiate()
		tcen.case = case
		%TestCaseList.add_child(tcen)
	
	%ProjectSwitch.button_down.connect(func() -> void:
		get_tree().change_scene_to_file("res://src/ProjectSelect/ProjectSelect.tscn")
	)
	
	%TestCaseTake.button_down.connect(func() -> void:
		get_tree().change_scene_to_file("res://src/TestCaseWindow/TestCaseWindow.tscn")
	)
	
	%TestCaseAdd.button_down.connect(func() -> void:
		Global.test_cases_ticked.clear()
		get_tree().change_scene_to_file("res://src/TestCaseEditor/TestCaseEditor.tscn")
	)
	
	%Credentials.button_down.connect(func() -> void:
		$CredentialsWindow.popup()
	)
