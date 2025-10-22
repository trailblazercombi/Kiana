class_name Project extends Node

const PROJECT_FILE_NAME = &"%sproject.kiana"

enum Tab {
	PROJECT,
	TESTS
}

static func DEFAULT() -> Dictionary:
	return {
		"mime" = Global.PROJECT_MIME,
		"title" = &"Unnamed Project",
		"description" = &"",
		"tab_at_open" = Tab.PROJECT,
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

var tab_at_open: Tab:
	get: return kiana_file[&"tab_at_open"]
	set(value): 
		kiana_file[&"tab_at_open"] = value
		save_to_disk()

var kiana_file: Dictionary
var folder: StringName

func _init(dir_or_file: StringName) -> void:
	sig_open_success.connect(func(yeah: bool) -> void:
		last_open_status = yeah
		is_open_happening = false
	)
	
	is_open_happening = true
	if dir_or_file.ends_with(&"project.kiana"):
		var json = JSON.new()
		json.parse(FileAccess.get_file_as_string(dir_or_file))
		if json.data == null:
			Global.popup_error(
				tr(&"This project is corrupted."),
				Global.open_project
			)
			sig_open_success.emit(false)
		else:
			kiana_file = Dictionary(json.data)
			folder = dir_or_file.trim_suffix(&"project.kiana")
			sig_open_success.emit(true)
	else:
		kiana_file = DEFAULT()
		folder = dir_or_file
		sig_open_success.emit(true)

func save_to_disk() -> void:
	var file := FileAccess.open(PROJECT_FILE_NAME % folder, FileAccess.WRITE)
	file.store_string(JSON.stringify(kiana_file, &"\t"))
	file.close()

func get_test_cases() -> Array[TestCase]:
	var test_cases: Array[TestCase] = []
	var dir := DirAccess.open(folder)
	var files: Array = Array(dir.get_files()).filter(
		func(file: String) -> bool: return file.begins_with(&"case_")
	)
	
	for file: String in files:
		test_cases.append(TestCase.new(file))
	
	return test_cases

func get_test_results() -> Array[TestResult]:
	var test_results: Array[TestResult] = []
	var dir := DirAccess.open(folder)
	var files: Array[StringName] = Array(dir.get_files()).filter(
		func(file: String) -> bool: return file.begins_with(&"result_")
	)
	
	for file: String in files:
		test_results.append(TestResult.new(file))
	
	return test_results

var is_open_happening: bool = false
var last_open_status: bool = false
signal sig_open_success(yeah: bool)

func open_success() -> bool:
	if not is_open_happening: return last_open_status
	return await sig_open_success
