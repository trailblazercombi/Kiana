class_name TestResultStepEntry extends FoldableContainer

var step: Dictionary = TestResult.EMPTY_STEP()

func _ready() -> void:
	title = &"%s: %s" % [
		TestResult.result_string(step[&"step_status"]),
		step[&"step_action"]
	]
	
	%ExpectedResult.text = step[&"step_expect"]
	%ActualResult.text = step[&"step_actual"]
