class_name ThrobberOverlay extends Panel

@export var message: StringName:
	get: return %Message.text
	set(value): %Message.text = value
