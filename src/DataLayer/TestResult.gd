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
		"start_time" = {},
		"submit_time" = {},
		"credentials" = {
			"tester_name" = &"Unnamed Tester",
			"system_info" = &""
		},
		"test_steps" = [],
		"overall_result" = StepStatus.NOT_EVALUATED
	}

static func EMPTY_STEP() -> Dictionary:
	return {
		"step_action" = &"",
		"step_expect" = &"",
		"step_actual" = &"",
		"step_status" = StepStatus.NOT_EVALUATED,
	}

var mime: StringName:
	set(value): kiana_file[&"mime"] = value
	get: return kiana_file[&"mime"]

var title: StringName:
	set(value): kiana_file[&"title"] = value
	get: return kiana_file[&"title"]

var description: StringName:
	set(value): kiana_file[&"description"] = value
	get: return kiana_file[&"description"]

var start_time: Dictionary:
	set(value): kiana_file[&"start_time"] = value
	get: return kiana_file[&"start_time"]

var submit_time: Dictionary:
	set(value): kiana_file[&"submit_time"] = value
	get: return kiana_file[&"submit_time"]

var credentials: Dictionary:
	set(value): kiana_file[&"credentials"] = value
	get: return kiana_file[&"credentials"]

var overall_result:
	set(value): kiana_file[&"overall_result"] = value
	get: return kiana_file[&"overall_result"]

var test_steps: Array:
	set(value): kiana_file[&"test_steps"] = value
	get: return kiana_file[&"test_steps"]

var kiana_file: Dictionary
var file_name: StringName

func _init(the_file_name: StringName) -> void:
	file_name = the_file_name
	
	if the_file_name == null or the_file_name == &"":
		while FileAccess.file_exists(full_file_path()):
			file_name = &"case_0_result_%s.kiana" % randi()
		kiana_file = DEFAULT()
	
	elif FileAccess.file_exists(full_file_path()):
		var json := JSON.new()
		json.parse(FileAccess.get_file_as_string(full_file_path()))
		kiana_file = DEFAULT().merged(Dictionary(json.data), true)
		if mime == Global.TEST_CASE_MIME:
			mime = Global.TEST_RESULT_MIME
			var old_name: StringName = file_name
			while FileAccess.file_exists(full_file_path()):
				file_name = &"result_%s_%s" % [randi(), old_name]
		
		if mime != Global.TEST_RESULT_MIME:
			Global.popup_error(
				tr(&"This is invalid. It may be corrupted or a different type."),
				Global.hide_throbber
			)
	
	else:
		Global.popup_error(
			tr(&"%s does not exist.") % full_file_path(),
			Global.hide_throbber
		)
		return
	
	for step: Dictionary in test_steps:
		step.merge(EMPTY_STEP())
	
	start_time = Time.get_datetime_dict_from_system()

func evaluate_step(num: int, act: StringName, stat: StepStatus) -> void:
	var step: Dictionary = test_steps[num]
	step[&"step_actual"] = act
	step[&"step_status"] = stat

func save_to_disk() -> void:
	submit_time = Time.get_datetime_dict_from_system()
	credentials = Global.credentials.get_json_dict()
	
	overall_result = StepStatus.NOT_EVALUATED
	for step in test_steps:
		match step[&"step_status"]:
			StepStatus.PASSED:
				overall_result = StepStatus.PASSED
				continue
			StepStatus.FAILED:
				overall_result = StepStatus.FAILED
				break
	
	var file := FileAccess.open(full_file_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(kiana_file, &"\t"))
	file.close()
	Global.refresh_data.emit()

func move_to_trash() -> void:
	OS.move_to_trash(full_file_path())
	Global.refresh_data.emit()

func full_file_path() -> StringName:
	return &"%s%s" % [Global.project.folder, file_name]

func overall_result_string() -> StringName:
	return result_string(overall_result)

static func result_string(status: StepStatus) -> StringName:
	match status:
		StepStatus.PASSED: return &"✅ Passed"
		StepStatus.FAILED: return &"🟥 Failed"
		_: return &"🔳 Not Evaluated"
