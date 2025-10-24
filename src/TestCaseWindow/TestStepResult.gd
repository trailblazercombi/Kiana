class_name TestStepResult extends ColorRect

const FAIL = Color("#e0003d")
const PASS = Color("#2d9f64")
const NO_EVAL = Color("#2d2d2d")

var step_number: StringName:
	get: return $Number.text
	set(value): $Number.text = value

# var color: built-in, edit to do the text
