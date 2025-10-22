class_name Project extends Node

const PROJECT_FILE_NAME = &"%s\\project.kiana"

static func DEFAULT() -> Dictionary:
	return {
		"title" = &"Unnamed Project",
		"description" = &"",
	}

var title: StringName:
	get: return kiana_file[&"title"]
	set(value):
		kiana_file[&"title"] = value
		save_to_disk()

var description: StringName:
	get: return kiana_file[&"description"]
	set(value): 
		kiana_file[&"description"] = value
		save_to_disk()

var kiana_file: Dictionary
var folder: StringName

func _init(dir_or_file: StringName) -> void:
	if dir_or_file.ends_with(&"project.kiana"):
		var json = JSON.new()
		json.parse(FileAccess.get_file_as_string(dir_or_file))
		kiana_file = Dictionary(json.data)
		folder = dir_or_file.trim_suffix(&"project.kiana")
	else:
		kiana_file = DEFAULT()
		folder = dir_or_file

func save_to_disk() -> void:
	var file := FileAccess.open(PROJECT_FILE_NAME % folder, FileAccess.WRITE)
	file.store_string(JSON.stringify(kiana_file, &"\t"))
