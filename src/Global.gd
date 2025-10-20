extends Node

var credentials: Credentials = Credentials.new("res://debug_data/credentials.txt")
var open_project: Project = null

var test_cases_ticked: Array[TestCase] = []
