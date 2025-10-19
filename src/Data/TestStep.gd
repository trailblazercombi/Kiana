## A single Test Case Step.
class_name TestStep extends GDScript

var action: StringName
var expected_result: StringName

func _init(the_action: StringName, the_expectations: StringName) -> void:
	action = the_action
	expected_result = the_expectations
