class_name TestCaseWindow extends MarginContainer

var test_case_queue: Array[TestCase] = []

var current_test: TestResult
var current_step: TestStep

func _ready() -> void:
	
	%EndTesting.disabled = true
	%NextCase.disabled = true
	%StepActual.editable = false
	%StepFail.disabled = true
	%StepPass.disabled = true
	%Previous.disabled = true
	%Next.disabled = true
	
	test_case_queue.append(
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
	)
)

	test_case_queue.append(
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
		)
	)

	test_case_queue.append(
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
		)
	)

	test_case_queue.append(
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
		)
	)

	test_case_queue.append(
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
	)

	
	%EndTesting.button_down.connect(func() -> void:
		end_test()
		%AutoAdvance.disabled = true
		print("Exit now!")
	)
	
	%NextCase.button_down.connect(func() -> void:
		end_test()
		start_test(test_case_queue.pop_front())
	)
	
	%StepActual.text_changed.connect(func() -> void:
		(current_test.step_results.get(current_step)
			as StepResult).actual_result_text = %StepActual.text
	)
	
	%StepFail.button_down.connect(func() -> void:
		(current_test.step_results.get(current_step)
			as StepResult).do_fail()
		%StepFail.disabled = true
		%StepPass.disabled = false
		if (
			%AutoAdvance.button_pressed 
			and current_test.case.has_next_step(current_step)
		):
			stop_step()
			start_step(current_test.next_step(current_step).front())
	)
	
	%StepPass.button_down.connect(func() -> void:
		(current_test.step_results.get(current_step)
			as StepResult).do_pass()
		%StepPass.disabled = true
		%StepFail.disabled = false
		
		if %StepActual.text == &"":
			%StepActual.text = %StepExpect.text
		
		if (
			%AutoAdvance.button_pressed 
			and current_test.case.has_next_step(current_step)
		):
			stop_step()
			start_step(current_test.next_step(current_step).front())
	)
	
	%Previous.button_down.connect(func() -> void:
		stop_step()
		start_step(current_test.previous_step(current_step).front())
		%AutoAdvance.button_pressed = false
	)
	
	%Next.button_down.connect(func() -> void:
		stop_step()
		start_step(current_test.next_step(current_step).front())
		%AutoAdvance.button_pressed = false
	)
	
	start_test(test_case_queue.pop_front())

func start_test(case: TestCase) -> void:
	if case == null: return
	if current_test != null: return
	
	current_test = TestResult.new(case)
	%TestCase.text = tr(&"Test Case: %s") % case.test_case_name
	if not test_case_queue.is_empty():
		%TestCase.text = tr(&"%s (%d cases left)") % [
			%TestCase.text, test_case_queue.size()
		]
	%TimeElapsed.text = tr(&"%s elapsed") % &"00:00"
	
	for step: StepResult in current_test.step_results.values():
		%ProgressBar.add_child(step)
	
	%StepNum.text = tr(&"Step %d of %d") % [1, current_test.step_results.size()]
	
	%EndTesting.disabled = false
	%NextCase.disabled = test_case_queue.is_empty()
	
	start_step(current_test.next_step(null).front())

func end_test() -> void:
	if current_test == null: return
	
	%EndTesting.disabled = true
	%NextCase.disabled = true
	%StepActual.editable = false
	%StepFail.disabled = true
	%StepPass.disabled = true
	%Previous.disabled = true
	%Next.disabled = true
	
	%TestCase.text = tr(&"No Test Case Loaded")
	%TimeElapsed.text = &""
	
	%StepAction.text = &""
	%StepExpect.text = &""
	%StepActual.text = &""
	
	for child: Node in %ProgressBar.get_children():
		%ProgressBar.remove_child(child)
	
	current_test = null

func start_step(step: TestStep) -> void:
	current_step = step
	%StepAction.text = current_step.action
	%StepExpect.text = current_step.expected_result
	%StepActual.text = (
		current_test.step_results.get(current_step) as StepResult
	).actual_result_text
	%StepActual.editable = true
	
	%Previous.disabled = not current_test.case.has_previous_step(step)
	%Next.disabled = not current_test.case.has_next_step(step)
	%StepNum.text = tr(&"Step %d of %d") % [
		current_test.case.current_step_num(step) + 1, 
		current_test.step_results.size()
	]
	
	%StepFail.disabled = (
		current_test.step_results.get(current_step) as StepResult
	).is_failed()
	
	%StepPass.disabled = (
		current_test.step_results.get(current_step) as StepResult
	).is_passed()

func stop_step() -> void:
	%StepActual.editable = false
	%StepFail.disabled = true
	%StepPass.disabled = true
	%Previous.disabled = true
	%Next.disabled = true
