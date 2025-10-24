class_name CredentialsWindow extends Window

func _ready() -> void:
	%Name.text = Global.credentials.tester_name
	%SystemInfo.text = Global.get_system_info()
	
	%Cancel.button_down.connect(func() -> void:
		%ThrobberOverlay.show()
		close_requested.emit()
	)
	
	%Save.button_down.connect(func() -> void:
		%ThrobberOverlay.show()
		Global.credentials.tester_name = %Name.text
		Global.credentials.save_to_disk()
		
		close_requested.emit()
	)

func _input(event: InputEvent) -> void:
	if event.is_action(&"ui_cancel"): close_requested.emit()
