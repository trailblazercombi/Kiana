class_name ProjectSelect extends MarginContainer

var recent_entry: PackedScene = preload("res://src/ProjectSelect/RecentEntry.tscn")

func _ready() -> void:
	get_window().title = tr(&"Kiana")
	
	%Create.button_down.connect(func() -> void:
		if await Global.create_project():
			get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%Load.button_down.connect(func() -> void:
		if await Global.open_project():
			get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	%Credentials.button_down.connect(func() -> void:
		Global.edit_credentials()
	)
	
	Global.refresh_data.connect(refresh_recents)
	refresh_recents()

func refresh_recents() -> void:
	for child in %Recents.get_children():
		child.queue_free()
	for entry: StringName in Global.credentials.recent_folders:
		var recent: RecentEntry = recent_entry.instantiate()
		recent.path = entry
		%Recents.add_child(recent)
