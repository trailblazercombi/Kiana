class_name StepCreateWindow extends Window

func _ready() -> void:
	%Cancel.button_down.connect(func() -> void:
		hide()
	)
	
	%Save.button_down.connect(func() -> void:
		hide()
	)
