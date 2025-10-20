class_name Project extends GDScript

var title: StringName
var description: StringName
var the_file_path: StringName = &""

var test_cases: Array[TestCase]
var test_results: Dictionary[TestCase, Array] # Array[TestResult]
