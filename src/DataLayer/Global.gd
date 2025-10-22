extends Node

const FILE_EXTENSION = &".kiana"
const PROJECT_MIME = &"project%s" % FILE_EXTENSION
const TEST_CASE_MIME = &"case%s" % FILE_EXTENSION
const TEST_RESULT_MIME = &"result%s" % FILE_EXTENSION

var dir: String

@warning_ignore("unused_signal")
signal refresh_data

enum Status {
	PASSED,
	FAILED,
	NOT_EVALUATED
}

func _ready() -> void:
	get_tree().root.add_child.call_deferred(_throbber)
	_throbber.z_index = 4090
	_throbber.hide()

#region The actual data

func get_system_info() -> String:
	var info := {}

	# --- OS & Locale ---
	info["OS Name"] = OS.get_name()
	info["OS Version"] = OS.get_version()
	info["Locale"] = OS.get_locale()
	#info["Host Name"] = OS.get_host_name()
	info["Unique ID"] = OS.get_unique_id()

	# --- CPU ---
	info["CPU Name"] = OS.get_processor_name()
	info["CPU Count"] = str(OS.get_processor_count())

	# --- Memory ---
	info["Static Memory Usage (MB)"] = str(OS.get_static_memory_usage() / (1024.0 * 1024.0))

	# --- Display ---
	info["Screen Count"] = str(DisplayServer.get_screen_count())
	info["Primary Screen Size"] = str(DisplayServer.screen_get_size())
	info["Window Size"] = str(DisplayServer.window_get_size())

	# --- GPU / Renderer ---
	var gpu_name := "Unknown"
	var gpu_vendor := "Unknown"
	var rd := RenderingServer.get_rendering_device()
	if rd:
		gpu_name = rd.get_device_name()
		#gpu_vendor = rd.get_vendor_name()

	info["GPU Name"] = gpu_name
	info["GPU Vendor"] = gpu_vendor

	# --- Engine ---
	var ver := Engine.get_version_info()
	info["Engine Version"] = ver.get("string", "Unknown")
	info["Executable Path"] = OS.get_executable_path()
	info["User Data Dir"] = OS.get_user_data_dir()

	# --- Environment variables (4.5 syntax) ---
	var env_keys := ["USERNAME", "USER", "COMPUTERNAME", "HOME", "APPDATA", "PATH"]
	var env_list: Array[String] = []
	for k in env_keys:
		if OS.has_environment(k):
			env_list.append("%s=%s" % [k, OS.get_environment(k)])
	info["Environment Vars"] = "\n" + "\n".join(env_list)

	# --- Disk info ---
	var user_dir := OS.get_user_data_dir()
	var disk_free := "Unknown"
	if DirAccess.dir_exists_absolute(user_dir):
		var da := DirAccess.open(user_dir)
		if da:
			disk_free = str(da.get_space_left() / (1024.0 * 1024.0)) + " MB free"
	info["Disk Info"] = "Free: %s (in %s)" % [disk_free, user_dir]

	# --- Combine ---
	var result := ""
	for key in info.keys():
		result += "%s: %s\n" % [key, info[key]]

	return result

#endregion
#region Contextual stuff

var project: Project = null

var credentials: Credentials = Credentials.new()

#endregion
#region Project file Reading and Writing

func open_project() -> bool:
	show_throbber(tr(&"Opening project..."))
	var flg: FileDialog = FileDialog.new()
	flg.transient = true
	flg.popup_window = true
	flg.size = Vector2i(900, 600)
	flg.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	flg.access = FileDialog.ACCESS_FILESYSTEM
	flg.add_filter("project.kiana")
	flg.use_native_dialog = true
	
	add_child(flg)
	flg.popup_centered()
		
	flg.file_selected.connect(func(file: String) -> void:
		credentials.add_to_recents(file)
		load_project(file),
		CONNECT_ONE_SHOT
	)
	
	flg.close_requested.connect(func() -> void:
		hide_throbber()
		flg.queue_free()
	)
	
	flg.canceled.connect(func() -> void:
		hide_throbber()
		flg.queue_free()
	)
	
	await flg.file_selected
	flg.queue_free()
	
	if await project.open_success():
		hide_throbber()
		return true
	else:
		hide_throbber()
		return false

func load_project(file_path: String) -> bool:
		show_throbber(tr(&"Opening %s" % file_path))
		project = Project.new(file_path)
		return await project.open_success()

func create_project() -> bool:
	show_throbber(tr(&"Creating project..."))
	var flg: FileDialog = FileDialog.new()
	flg.transient = true
	flg.popup_window = true
	flg.size = Vector2i(900, 600)
	flg.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	flg.access = FileDialog.ACCESS_FILESYSTEM
	flg.use_native_dialog = true
	
	add_child(flg)
	flg.popup_centered()
	
	flg.dir_selected.connect(func(the_dir: String) -> void:
		dir = the_dir,
		CONNECT_ONE_SHOT
	)
	
	flg.close_requested.connect(func() -> void:
		hide_throbber()
		flg.queue_free()
	)
	
	flg.canceled.connect(func() -> void:
		hide_throbber()
		flg.queue_free()
	)
	
	await flg.dir_selected
	var dir_access: DirAccess = DirAccess.open(dir)
	if dir_access.file_exists(&"project.kiana"):
		popup_error(
			&"A project already exists here.",
			func() -> void: 
				hide_throbber()
				create_project()
		)
		return false
	else:
		project = Project.new(dir)
		hide_throbber()
		flg.queue_free()
		credentials.add_to_recents(&"%sproject.kiana" % dir)
		return true

func edit_credentials() -> void:
	show_throbber(tr(&"Editing credentials..."))
	var cred_win: CredentialsWindow = preload(
		"res://src/CredentialsWindow/CredentialsWindow.tscn"
	).instantiate()
	get_tree().root.add_child(cred_win)
	cred_win.show()
	
	cred_win.close_requested.connect(func() -> void:
		hide_throbber()
		cred_win.queue_free()
	)

#endregion
#region Throbber (full-screen overlay)

var _throbber: ThrobberOverlay = preload(
	"res://src/ThrobberOverlay/ThrobberOverlay.tscn"
).instantiate()

func show_throbber(message: StringName) -> void:
	_throbber.message = message
	_throbber.show()

func hide_throbber() -> void:
	_throbber.hide()

func popup_error(message: StringName, ok_action: Callable) -> void:
	var error := AcceptDialog.new()
	error.dialog_close_on_escape = true
	error.dialog_text = tr(message)
	error.dialog_hide_on_ok = true
	error.force_native = true
	error.confirmed.connect(ok_action, CONNECT_ONE_SHOT)
	
	get_tree().root.add_child(error)
	error.popup_centered()

var last_known_test_case_edit_path: StringName

func edit_test_case(file_path: StringName) -> void:
	last_known_test_case_edit_path = file_path
	get_tree().change_scene_to_file("res://src/TestCaseEditor/TestCaseEditor.tscn")

func quit() -> void:
	get_tree().quit()

#endregion
