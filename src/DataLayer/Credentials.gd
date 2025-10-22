class_name Credentials extends Node

const PATH = "user://credentials.kiana"

static func DEFAULT() -> Dictionary:
	return {
		"tester_name" = "Unnamed Tester"
	}

var kiana_file: Dictionary

var tester_name: StringName:
	get: return kiana_file["tester_name"]
	set(value): kiana_file["tester_name"] = value

func _init() -> void:
	if FileAccess.file_exists(PATH):
		var json = JSON.new()
		json.parse(FileAccess.get_file_as_string(PATH))
		kiana_file = Dictionary(json.data)
	else: kiana_file = DEFAULT()

func save_to_disk() -> void:
	var file := FileAccess.open(PATH, FileAccess.WRITE)
	file.store_string(JSON.stringify(kiana_file, &"\t"))
