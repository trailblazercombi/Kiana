class_name ProjectSelect extends MarginContainer

func _ready() -> void:
	%Create.button_down.connect(func() -> void:
		await Global.create_project()
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%Load.button_down.connect(func() -> void:
		await Global.open_project()
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%Credentials.button_down.connect(func() -> void:
		Global.edit_credentials()
	)
