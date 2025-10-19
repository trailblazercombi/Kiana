## A data class for packaging test results into something normal.
##
## This class takes a test case and puts a result to it.
class_name TestResult extends GDScript

var case: TestCase
var step_results: Dictionary[TestStep, StepResult]

var time_start: Dictionary = Time.get_datetime_dict_from_system()

func _init(the_case: TestCase) -> void:
	case = the_case
	for step: TestStep in case.test_case_steps:
		step_results.set(
			step, 
			preload("res://src/Data/StepResult.tscn").instantiate()
		)

func next_step(current: TestStep) -> Array[Variant]:
	if current == null:
		var ze_next: TestStep = case.test_case_steps.front()
		return [ze_next, step_results.get(ze_next)]

	if not case.has_next_step(current): return []
	
	var next := case.next_step(current)
	return [next, step_results.get(next)]

func previous_step(current: TestStep) -> Array[Variant]:
	if not case.has_previous_step(current): return []
	
	var next := case.previous_step(current)
	return [next, step_results.get(next)]

func add_text(current: TestStep, text: StringName) -> void:
	(step_results.get(current) as StepResult).actual_result_text = text

func pass_step(current: TestStep) -> void:
	(step_results.get(current) as StepResult).do_pass()

func fail_step(current: TestStep) -> void:
	(step_results.get(current) as StepResult).do_fail()
