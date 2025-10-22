class_name StepCreateWindow extends Window

signal done
var _step: TestStepEntry

func _ready() -> void:
	%Cancel.button_down.connect(func() -> void: done.emit())
	
	%Save.button_down.connect(func() -> void:
		%ThrobberOverlay.show()
		_step.update_data(%Action.text, %Expected.text)
		done.emit()
	)
	
	close_requested.connect(func() -> void: done.emit())

func _input(event: InputEvent) -> void:
	if event.is_action(&"ui_cancel"): close_requested.emit()

func edit_step(step: TestStepEntry) -> TestStepEntry:
	_step = step
	%ThrobberOverlay.hide()
	force_native = true
	%Action.text = step.step[&"step_action"]
	%Expected.text = step.step[&"step_expect"]
	popup_centered()
	
	await done
	if %Action.text.is_empty() and %Expected.text.is_empty():
		_step.delete.emit()
	return step
