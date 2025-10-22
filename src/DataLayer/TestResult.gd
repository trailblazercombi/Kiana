class_name TestResult extends Node

enum StepStatus {
	NOT_EVALUATED,
	PASSED,
	FAILED,
}

static func DEFAULT() -> Dictionary:
	return {
		"mime" = Global.TEST_RESULT_MIME,
		"title" = &"",
		"description" = &"",
		"credentials" = {
			"tester_name" = &"Unnamed Tester",
			"system_info" = &""
		},
		"test_steps" = [],
	}

static func EMPTY_STEP() -> Dictionary:
	return {
		"step_action" = &"",
		"step_expect" = &"",
		"step_actual" = &"",
		"step_status" = StepStatus.NOT_EVALUATED,
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
		var json := JSON.new()
		json.parse(FileAccess.get_file_as_string(full_file_path()))
		kiana_file = DEFAULT().merged(Dictionary(json.data), true)
		if kiana_file[&"mime"] != Global.TEST_RESULT_MIME:
			Global.popup_error(
				tr(&"This is invalid. It may be corrupted or a different type."),
				Global.hide_throbber
			)
	
	else:
		Global.popup_error(
			tr(&"This does not exist. It may have been modified or removed."),
			Global.hide_throbber
		)
		return
	
	kiana_file[&"credentials"] = Global.credentials.get_json_dict()

func add_step(
	action: StringName,
	expected_result: StringName,
	actual_result: StringName,
	step_status: StepStatus
) -> void:
	var step = EMPTY_STEP()
	if action != &"": 
		kiana_file[&"step_action"] = action
	if expected_result != &"":
		kiana_file[&"step_expect"] = expected_result
	if actual_result != &"": 
		kiana_file[&"step_actual"] = actual_result
	if step_status != StepStatus.NOT_EVALUATED: 
		kiana_file[&"step_status"] = step_status
	kiana_file[&"test_steps"].append(step)

func save_to_disk() -> void:
	var file := FileAccess.open(full_file_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(kiana_file, &"\t"))
	file.close()
	Global.refresh_data.emit()

func move_to_trash() -> void:
	OS.move_to_trash(full_file_path())
	Global.refresh_data.emit()

func full_file_path() -> StringName:
	return &"%s\\%s" % [Global.project.folder, file_name]
