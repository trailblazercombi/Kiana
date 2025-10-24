class_name TestCaseResultViewer extends MarginContainer

var found_results: Array[TestResult]

func _ready() -> void:
	Global.show_throbber(tr(&"Working..."))
	
	var dir := DirAccess.open(Global.project.folder)
	for file: String in dir.get_files():
		if file.contains(
			Global.selected_test_cases.front().file_name
		) and file.begins_with("result"):
			found_results.append(TestResult.new(file))
	
	found_results.sort_custom(func(a: TestResult, b: TestResult) -> bool:
		return Time.get_unix_time_from_datetime_dict(
			a.submit_time
		) > Time.get_unix_time_from_datetime_dict(
			b.submit_time
		)
	)
	
	for i: int in range(found_results.size()):
		var result: TestResult = found_results[i]
		%ResultSwitcher.add_item(
			tr(&"%s: %s @ %s") % [
				result.overall_result_string(),
				result.credentials[&"tester_name"],
				Time.get_datetime_string_from_datetime_dict(
					result.submit_time, true
				)
			], i
		)
	
	%Title.text = Global.selected_test_cases.front().title
	%Description.text = Global.selected_test_cases.front().description
	
	%ResultSwitcher.item_selected.connect(select_item)
	%ResultSwitcher.item_focused.connect(select_item)
	
	%Close.button_down.connect(func() -> void:
		get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
	)
	
	select_item(0)
	Global.hide_throbber()

func select_item(i: int) -> void:
	Global.show_throbber(tr(&"Working..."))
	for child in %ResultsList.get_children():
		child.queue_free()
	
	if found_results.is_empty():
		Global.popup_error(&"No results found!", func() -> void:
			get_tree().change_scene_to_file("res://src/ProjectWindow/ProjectWindow.tscn")
		)
		
	var result: TestResult = found_results.get(i)
	#print(result.kiana_file)
	
	if result == null:
		Global.popup_error(&"Result is invalid!", func() -> void:
			select_item(0)
		)
	
	for child in %ResultsList.get_children(): child.queue_free()
	
	#%Tester.text = result.kiana_file[&"credentials"][&"tester_name"]
	#%TimeFinish.text = Time.get_datetime_string_from_datetime_dict(
		#result.kiana_file[&"submit_time"],
		#true
	#)
	%SystemInfo.text = result.kiana_file[&"credentials"][&"system_info"]
	
	for step_content: Dictionary in result.test_steps:
		var step: TestResultStepEntry = preload(
			"res://src/TestCaseResultViewer/TestResultStepEntry.tscn"
		).instantiate()
		
		step.step = step_content
		%ResultsList.add_child(step)
	
	Global.hide_throbber()
