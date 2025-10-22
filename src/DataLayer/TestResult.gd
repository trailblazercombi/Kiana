class_name TestResult extends Node

var title: StringName
var description: StringName

var tester_name: StringName
var tester_environment: StringName
var test_start_time: int
var test_end_time: int

var test_steps: Array[TestResultStep]
