class_name Credentials extends GDScript

var the_file_path: StringName
var tester_name: StringName

func _init(file_path: StringName) -> void:
	the_file_path = file_path
	
	var file_open: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	tester_name = file_open.get_as_text()

func save() -> void:
	var file_open: FileAccess = FileAccess.open(the_file_path, FileAccess.WRITE)
	file_open.store_string(tester_name)
