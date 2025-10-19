class_name StepResult extends Label

var actual_result_text: StringName

func do_pass() -> void:
	text = tr(&"🟩")

func do_fail() -> void:
	text = tr(&"🟥")

func is_passed() -> bool:
	return text == tr(&"🟩")

func is_failed() -> bool:
	return text == tr(&"🟥")

func is_evaluated() -> bool:
	return not is_passed() and not is_failed()
