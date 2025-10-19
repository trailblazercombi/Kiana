## A data class for packaging Test Cases.
##
## This contains the test case description and the individual steps & actions.
class_name TestCase extends GDScript

func _init(
	the_name: StringName,
	the_desc: StringName,
	the_steps: Array[TestStep]
) -> void:
	test_case_name = the_name
	test_case_description = the_desc
	test_case_steps = the_steps

var test_case_name: StringName
var test_case_description: StringName

var test_case_steps: Array[TestStep]

func has_next_step(current: TestStep) -> bool:
	return current_step_num(current) < test_case_steps.size() - 1

func has_previous_step(current: TestStep) -> bool:
	return current_step_num(current) > 0

func next_step(current: TestStep) -> TestStep:
	return test_case_steps.get(current_step_num(current) + 1)

func previous_step(current: TestStep) -> TestStep:
	return test_case_steps.get(current_step_num(current) - 1)

func current_step_num(current: TestStep) -> int:
	return test_case_steps.find(current)
