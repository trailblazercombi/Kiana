class_name Credentials extends Node

const PATH = "user://credentials.kiana"

static func DEFAULT() -> Dictionary:
	return {
		"tester_name" = &"Unnamed Tester",
		"system_info" = &"",
		"recent_folders" = [],
	}

var kiana_file: Dictionary

var tester_name: StringName:
	get: return kiana_file["tester_name"]
	set(value): kiana_file["tester_name"] = value

var recent_folders: Array:
	get: return kiana_file["recent_folders"]
	set(value):
		kiana_file["recent_folders"] = value
		save_to_disk()

func _init() -> void:
	if FileAccess.file_exists(PATH):
		var json = JSON.new()
		json.parse(FileAccess.get_file_as_string(PATH))
		kiana_file = Dictionary(json.data).merged(DEFAULT())
	else: kiana_file = DEFAULT()

func save_to_disk() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(kiana_file, &"\t"))
	file.close()

func add_to_recents(folder: StringName) -> void:
	if recent_folders.find(folder) < 0: 
		recent_folders.append(folder)
		save_to_disk()

func remove_from_recents(folder: String) -> void:
	recent_folders.erase(folder)
	save_to_disk()

func get_json_dict() -> Dictionary:
	return kiana_file.merged({ "system_info" = Global.get_system_info() }, true)
