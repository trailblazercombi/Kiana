class_name RecentEntry extends HBoxContainer

var path: StringName = &""

func _ready() -> void:
	$Path.text = path
	$Load.button_down.connect(func() -> void: 
		if await Global.load_project(path):
			get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	$Remove.button_down.connect(func() -> void: 
		Global.credentials.remove_from_recents(path)
		Global.refresh_data.emit()
	)
