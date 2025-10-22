class_name TestStepEntry extends MarginContainer

var root: Node
var step: Dictionary = TestCase.EMPTY_STEP()

signal move_up
signal move_down
signal edit
signal delete

func _ready() -> void:
	%Action.text = step[&"step_action"]
	%ExpectedResult.text = step[&"step_expect"]
	
	%MoveUp.button_down.connect(func() -> void: move_up.emit())
	%MoveDown.button_down.connect(func() -> void: move_down.emit())
	%Edit.button_down.connect(func() -> void: edit.emit())
	%Delete.button_down.connect(func() -> void: delete.emit())

func update_data(action: StringName, expect: StringName) -> void:
	step[&"step_action"] = action
	%Action.text = action
	
	step[&"step_expect"] = expect
	%ExpectedResult.text = expect
