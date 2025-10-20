class_name CredentialsWindow extends Window

func _ready() -> void:
	%Cancel.button_down.connect(func() -> void:
		hide()
	)
	
	%Confirm.button_down.connect(func() -> void:
		Global.credentials.tester_name = %Name.text
		Global.credentials.save()
		hide()
	)
	
	about_to_popup.connect(func() -> void:
		%Name.text = Global.credentials.tester_name
	)
