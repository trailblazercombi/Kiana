class_name TestCase extends Node

static func DEFAULT() -> Dictionary:
	return {
		"mime" = Global.TEST_CASE_MIME,
		"title" = &"",
		"description" = &"",
		"test_steps" = [],
	}

static func EMPTY_STEP() -> Dictionary:
	return {
		"step_action" = &"",
		"step_expect" = &"",
	}

var title: StringName
var description: StringName

var kiana_file: Dictionary
var file_name: StringName

func _init(the_file_name: StringName) -> void:	
	if the_file_name == null or the_file_name == &"":
		while FileAccess.file_exists(full_file_path()):
			file_name = &"result_%s.kiana" % randi()
		kiana_file = DEFAULT()
	
	elif FileAccess.file_exists(full_file_path()):
		file_name = the_file_name
		var json = JSON.new()
		json.parse(FileAccess.get_file_as_string(full_file_path()))
		kiana_file = Dictionary(json.data)
	
	else:
		Global.popup_error(
			tr(&"Test Case does not exist."),
			func() -> void:
				Global.hide_throbber()
		)

func add_step(
	action: StringName,
	expected_result: StringName,
) -> void:
	var step = EMPTY_STEP()
	if action != &"": 
		kiana_file[&"step_action"] = action
	if expected_result != &"": 
		kiana_file[&"step_expect"] = expected_result
	kiana_file[&"test_steps"].append(step)

func save_to_disk() -> void:
	var file := FileAccess.open(full_file_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(kiana_file, &"\t"))
	file.close()

func full_file_path() -> StringName:
	return &"%s\\%s" % [Global.project.folder, file_name]
