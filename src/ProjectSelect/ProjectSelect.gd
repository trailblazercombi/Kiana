class_name ProjectSelect extends CenterContainer

func _ready() -> void:
	%Create.button_down.connect(func() -> void:
		Global.open_project = Project.new()
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%Load.button_down.connect(func() -> void:
		pass
	)
