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

var title: StringName:

	get: return kiana_file[&"title"]
	set(value): kiana_file[&"title"] = value

var description: StringName:
	get: return kiana_file[&"description"]
	set(value): kiana_file[&"description"] = value

var test_steps: Array:
	get: return kiana_file[&"test_steps"]
	set(value): kiana_file[&"test_steps"] = value.duplicate_deep()

var kiana_file: Dictionary
var file_name: StringName

func _init(the_file_name: StringName) -> void:	
	file_name = the_file_name
	
	if the_file_name == null or the_file_name == &"":
		file_name = &"case_%s.kiana" % randi()
		while FileAccess.file_exists(full_file_path()):
			file_name = &"case_%s.kiana" % randi()
		kiana_file = DEFAULT()
	
	elif FileAccess.file_exists(full_file_path()):
		var json = JSON.new()
		json.parse(FileAccess.get_file_as_string(full_file_path()))
		kiana_file = Dictionary(json.data)
	
	else:
		Global.popup_error(
			tr(&"Test Case does not exist."),
			func() -> void:
				Global.hide_throbber()
		)

#func add_step(
	#action: StringName,
	#expected_result: StringName,
	#index: int = -1 # -1 appends to the end
#) -> void:
	#var step = EMPTY_STEP()
	#if action != &"": 
		#kiana_file[&"step_action"] = action
	#if expected_result != &"": 
		#kiana_file[&"step_expect"] = expected_result
	#(kiana_file[&"test_steps"] as Array).insert(step, index)
	#Global.refresh_data.emit()
#
#func remove_step(index: int) -> void:
	#(kiana_file[&"test_steps"] as Array).remove_at(index)
	#Global.refresh_data.emit()

func get_all_steps() -> Array:
	return (kiana_file[&"test_steps"] as Array)

func save_to_disk() -> void:
	var file := FileAccess.open(full_file_path(), FileAccess.WRITE)
	file.store_string(JSON.stringify(kiana_file, &"\t"))
	file.close()
	Global.refresh_data.emit()

func move_to_trash() -> void:
	OS.move_to_trash(full_file_path())
	Global.refresh_data.emit()

func full_file_path() -> StringName:
	return &"%s%s" % [Global.project.folder, file_name]
