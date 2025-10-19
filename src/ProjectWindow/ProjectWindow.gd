class_name ProjectWindow extends MarginContainer

var credentials: StringName = &""
var test_cases: Array[TestCase] = [
	
	TestCase.new(
		tr(&"Test Login Functionality"),
		tr(&"Checks user can successfully log in."),
		[
			TestStep.new(&"Open Login Page", &"Navigate to the login screen."),
			TestStep.new(&"Enter Credentials", &"Input valid username and password."),
			TestStep.new(&"Submit Form", &"Click the login button and wait for response."),
			TestStep.new(&"Verify Redirect", &"Confirm user is taken to dashboard."),
			TestStep.new(&"Check Session", &"Ensure valid session token is stored."),
		]
	),
	
	TestCase.new(
		tr(&"Test Inventory System"),
		tr(&"Verifies that item pickup and removal work correctly."),
		[
			TestStep.new(&"Pick Up Item", &"Add an item to inventory."),
			TestStep.new(&"Check Item Count", &"Ensure inventory shows correct quantity."),
			TestStep.new(&"Equip Item", &"Equip the picked-up item to player slot."),
			TestStep.new(&"Use Item", &"Consume or activate the equipped item."),
			TestStep.new(&"Remove Item", &"Drop or delete item from inventory."),
			TestStep.new(&"Verify Empty Slot", &"Ensure slot is cleared after removal."),
		]
	),
	
	TestCase.new(
		tr(&"Test Enemy AI Patrol"),
		tr(&"Confirms enemies patrol correctly between waypoints."),
		[
			TestStep.new(&"Spawn Enemy", &"Instantiate enemy at start position."),
			TestStep.new(&"Observe Patrol", &"Enemy should move between patrol points."),
			TestStep.new(&"Interrupt Patrol", &"Enemy reacts when player enters detection range."),
			TestStep.new(&"Return to Patrol", &"Enemy resumes route when player leaves range."),
			TestStep.new(&"Despawn Enemy", &"Clean up enemy instance after test."),
		]
	),

	TestCase.new(
		tr(&"Test Save and Load Feature"),
		tr(&"Ensures game state is saved and restored properly."),
		[
			TestStep.new(&"Save Progress", &"Trigger save function with current state."),
			TestStep.new(&"Modify State", &"Move player and change stats to simulate progress."),
			TestStep.new(&"Reload Game", &"Restart and load saved data."),
			TestStep.new(&"Verify State", &"Check that player position and stats match previous session."),
			TestStep.new(&"Attempt Invalid Load", &"Ensure corrupted file fails gracefully."),
			TestStep.new(&"Auto-Save Trigger", &"Confirm auto-save activates on checkpoint."),
		]
	),
	
	TestCase.new(
		tr(&"Test Audio Settings"),
		tr(&"Checks that volume sliders affect output volume."),
		[
			TestStep.new(&"Open Settings", &"Navigate to audio settings page."),
			TestStep.new(&"Adjust Master Volume", &"Change overall sound level."),
			TestStep.new(&"Adjust Music Volume", &"Change background music slider."),
			TestStep.new(&"Adjust SFX Volume", &"Modify sound effects volume slider."),
			TestStep.new(&"Confirm Effect", &"Ensure in-game sounds reflect new settings."),
			TestStep.new(&"Mute Toggle", &"Check mute button silences all audio."),
			TestStep.new(&"Unmute", &"Ensure sounds return when mute is toggled off."),
		]
	)
]

func _ready() -> void:
	var ptce: PackedScene = preload("res://src/ProjectWindow/TestCaseEntry.tscn")
	for case: TestCase in test_cases:
		var tcen: TestCaseEntry = ptce.instantiate()
		tcen.set_data(false, case.test_case_name, case.test_case_description)
		%TestCaseList.add_child(tcen)
	
	%TestCaseTake.button_down.connect(func() -> void:
		var tcw: TestCaseWindow = preload(
			"res://src/TestCaseWindow/TestCaseWindow.tscn"
		).instantiate()
		tcw.test_case_queue = %TestCaseList.get_children().filter(
			func(case: TestCaseEntry) -> bool: return case.selected()
		)
	)
