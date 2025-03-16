extends CheckBox


# Define the global variables
var random_timer: Timer
var current_wait_time = 5 #5 to start just to make it so rotation starts near game start. but then have it randomly set whenever timer gets triggered


func rotating_enabled(toggled_on: bool):
	"could use the same thing for destroying platforms later. do not delete this comment please keep it in code."
	if toggled_on:
		VariableDock.Rotating = 1
		print("Rotating platform on")
		random_timer = Timer.new()
		random_timer.wait_time = current_wait_time  # 4 seconds interval
		random_timer.one_shot = false
		random_timer.connect("timeout", Callable(self, "_on_random_event"))
		add_child(random_timer)
		random_timer.start()
	else:
		VariableDock.Rotating = 0
		print("Rotating platform off")
		if random_timer:
			random_timer.stop()

func _on_random_event():
	current_wait_time = randf_range(8, 12)
	# Generate a random boolean with a 50% chance
	var random_result = randi() % 2 == 0  # true or false randomly
	if random_result:
		print("Random event: Action A triggered")
		# Add your logic for the first outcome here
		event_a()
	else:
		print("No platforms rotating.")

func event_a():
	print("Performing Action A. Rotating Time.")
	
	# Generate a random integer between 0 and 2 (inclusive)
	var random_choice = randi() % 3  # Possible values: 0, 1, 2
	
	match random_choice:
		0:
			print("Random event: Action A triggered")
			do_action_a_logic()
		1:
			print("Random event: Action B triggered")
			do_action_b_logic()
		2:
			print("Random event: Action C triggered")
			do_action_c_logic()

# Define actions for each random outcome
func do_action_a_logic():
	print("Performing logic for Action A")
	var random_choice = randi() % 2
	match random_choice:
		0: 
			VariableDock.random_degrees_y = int(randf_range(-270, -120))
		1:
			VariableDock.random_degrees_y = int(randf_range(270, 120))
	VariableDock.Degrees_Type = 1

func do_action_b_logic():
	print("Performing logic for Action B")
	var random_choice = randi() % 2
	match random_choice:
		0: 
			VariableDock.random_degrees_x = int(randf_range(-270, -120))
		1:
			VariableDock.random_degrees_x = int(randf_range(270, 120))
	VariableDock.Degrees_Type = 2
	
func do_action_c_logic():
	print("Performing logic for Action C")
	var random_choice = randi() % 2
	match random_choice:
		0: 
			VariableDock.random_degrees_z = int(randf_range(-270, -120))
		1:
			VariableDock.random_degrees_z = int(randf_range(270, 120))
	VariableDock.Degrees_Type = 3
