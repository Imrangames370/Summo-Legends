extends Node3D

const DUST_CLOUD = preload("res://Scenes/DustCloud.tscn")
const TURBO_BUBBLE = preload("res://Scenes/TurboBubble.tscn")


"""PLAYER NUMBER START"""
var player_number = -1 #use 0 for player number 10's player number cuz arrays cannot have values at 10 or higher
var controller_number = 7 #leave at -1 for non controller scripts. manually set. used only for controller connections with player_1_controller to player_8 controller
var keyboard_connect_tracker = 0 #ensures a single script does not connet to keyboard twice. without this to prevent it from connecting twice u would get player number duplicates.
"""PLAYER NUMBER END"""
@onready var top_down_camera_3d: Camera3D = $"../../TopDownCamera3D" #used for forcing label to face camera
@onready var sumo_section: Node3D = $"../../SUMO SECTION"
@onready var player_skin_interface_base_screen: Control = $"../../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen"
var variable_ready_skin_and_button_defaults = 1
@onready var player_manager: Node = $".."

"""PLAYER CONNECT START"""
#adding a check with an if variable before essentially every function so nothing runs if there is no input. 
#essentially upon getting a input from the player, it connects the player to the game. i.e. all its functions can be used and it spawns
#on mobile this would just be if any control on mobile gets pressed it would connect the player.
"""PLAYER CONNECT END"""

"""STEALTH START"""
var stealth_timer: Timer #for auto exit
var last_material #essential for resetting stealth

"""STEALTH END"""
"""IN GAME PLATFORM MENU START"""
var selected_index = 0
var buttons := []
var menu_instance: Control = null
var canvas_layer: CanvasLayer = null
var menu_timer: Timer #for auto exit

"""IN GAME PLATFORM MENU END"""

"""PLAYER NAME LABEL 3D PROPERTIES START"""
const Orbitron_Bold = preload("res://Assets/fonts/Orbitron-Bold.otf")

var global_player_transform #used for player transform all throughout the script, variable is updated constantly in physics_process
var x_offset_factor #IMPORTANT USED FOR OFFESTTING IN DYNAMIC LABEL 3D AS CAMERA RISES
"""PLAYER NAME LABEL 3D PROPERTIES END"""

#later for bounce issues can add a second ray just as a backup for resetting to make bounce issues less likely. i think it has
#to do with bouncing on the same segment or collision shape twice though so another ray wouldnt help
"""DEATH CHECK VARIABLE START"""
# Player life state variables
var death_status = 0
var player_reset_tracker = 2
var player_dead_trigger = 0
var settings_player_lives = 1
var player_respawn_trigger = 0
# Signal
"""DEATH CHECK VARIABLE END"""

"""ENERGY START"""
var current_energy: int = 300
var regular_energy_max: int = 300
var overflow_energy_max = regular_energy_max * 2
var time_accumulator = 0.0
var overflow_energy_loss_per_second
"""EMERGY END"""

"""PLAYER COLOR"""
var player_platform_paint_color_r = 0
var player_platform_paint_color_g = 0
var player_platform_paint_color_b = 0

"""PLAYER COLOR END"""

"""PLAYER CYCLE PLATFORM CONTROL"""
var shift_pressed = false  # Track shift state
"""PLAYER CYCLE PLATFORM CONTROL END"""

"""RAM ABILITY"""
@export var input_window = 1.5  # Timeframe in seconds for double input
"""RAM ABILITY END"""

# Tracking variables
var input_timestamps = {}

var objects = []
@onready var mesh
@onready var obj_shape = SphereShape3D.new()
@onready var sphere_collision = CollisionShape3D.new()
var max_jumps = 1
var available_jumps = max_jumps


@export var time_with_low_velocity = 0

var bounce_reset_threshold = 3  # Number of jumps to trigger bounce reset
var bounce_reset_timeframe = 4.0  # Timeframe in seconds to count jumps

#customizeable jump and speed modifiers. 1 is no change. can add sliders for changing them easily.
# really between .5 to 5 is as extreme as it should get. maybe even 2 or 3 max honestly.
var speed_modifier = 1 #changes speed modifier in movement commands

var speed_damp_modifier = .3 #IMPORTANT MUST USE A low step like .1 in editor because you'll need to make .1 the min and like 5 the max.
#speed_damp_modifier 1 is the default. higher values mean slower character. lower mean faster. This is the best value for sliders.

"""RAY DETECTION BEGIN"""
# Ground detection
var is_on_ground: bool = false
# Ground detection parameters
@export var ground_layer = 1  # Ensure the ground is on this layer
@export var energy_orb_layer = 2  # Ensure the ground is on this layer
# Distance from ray to detect ground. Could make it longer so its more likely to detect then just add a one second jump cooldown so they
# cant glitch a free double jump by clicking space twice quickly.
var ground_detection_distance = 2.1
var energy_orb_detection_distance = 1.1

"""RAY DETECTION END"""

"""RAPID INPUT DETECTION START"""
var actions = []
"""RAPID INPUT DETECTION END"""

var delete_player_tracker = 2 #default is 1.
var create_player_tracker = 1 #default is 1.
var surviving_player_deletion_ensure = 0

func _update_energy_display(delta):

	for entry in objects:
		var energy_outline = entry[4]
		var energy_fill = entry[5]
		energy_fill.position = energy_outline.position + Vector3(0, 0, 0.04)
		var fill_ratio: float
		var is_overflow = current_energy > regular_energy_max
		if is_overflow:
			fill_ratio = (current_energy - regular_energy_max) / float(overflow_energy_max - regular_energy_max)
			energy_fill.modulate = Color(1.0, 0.5 - fill_ratio * 0.5, 0.0)  # Yellow to red
			# Shake effect
			var shake_intensity = fill_ratio * 0.1
			var x_offset = fill_ratio * .75 
			energy_outline.position = Vector3(
				randf_range(-shake_intensity, shake_intensity) - 4.75 - x_offset,
				randf_range(-shake_intensity, shake_intensity) + 6,
				0.02
			)
			energy_fill.position = energy_outline.position + Vector3(0, 0, 0.04) #update quickly right after doing shake
		else:
			fill_ratio = current_energy / float(regular_energy_max)
			var x_offset = fill_ratio * .75
			energy_outline.position = Vector3(-4.75 - x_offset, 6, 0.02) 
			energy_fill.modulate = Color.YELLOW
			energy_fill.position = energy_outline.position + Vector3(0, 0, 0.04) #RESET POSITION POST SHAKE
		
		if is_overflow:
			energy_fill.scale.x = clamp(fill_ratio, 0.0, 1.0)
			energy_outline.scale.x = clamp(fill_ratio, 0.0, 1.0)
			energy_fill.scale.y = clamp(fill_ratio, 0.0, 1.0)
			energy_outline.scale.y = clamp(fill_ratio, 0.0, 1.0)
		else:
			energy_fill.scale.x = clamp(fill_ratio, 0.0, 1.0)
			energy_outline.scale.x = clamp(fill_ratio, 0.0, 1.0)
			energy_fill.scale.y = clamp(fill_ratio, 0.0, 1.0)
			energy_outline.scale.y = clamp(fill_ratio, 0.0, 1.0)

func create_sphere(pos: Vector3):
	var sphere_node = Node3D.new()
	add_child(sphere_node)
	sphere_node.position = pos
	var ps = PhysicsServer3D
	var rs = RenderingServer
	
	# Create the physics body
	var object = ps.body_create()
	# Store the physics object in the Node3D
	sphere_node.set_meta("physics_object", object)
	ps.body_set_space(object, get_world_3d().space)
	ps.body_add_shape(object, obj_shape)
	ps.body_set_mode(object, PhysicsServer3D.BODY_MODE_RIGID)
	ps.body_set_param(object, PhysicsServer3D.BODY_PARAM_FRICTION, 0.3)
	ps.body_set_param(object, PhysicsServer3D.BODY_PARAM_LINEAR_DAMP, 0.05)
	ps.body_set_param(object, PhysicsServer3D.BODY_PARAM_BOUNCE, VariableDock.base_bounce_all_players)
	ps.body_set_param(object, PhysicsServer3D.BODY_PARAM_ANGULAR_DAMP, 0.01)
	ps.body_set_enable_continuous_collision_detection(object, true)
	ps.body_set_shape_transform(object, 0, Transform3D(Basis.IDENTITY, Vector3.ZERO))
	
	# Set collision layer and mask
	var layer = 1  # Belongs to layer 1
	var mask = 1 | 2  # Collides with layers 1 and 2
	ps.body_set_collision_layer(object, layer)
	ps.body_set_collision_mask(object, mask)
	
	# Set the transform
	var trans = Transform3D(Basis.IDENTITY, pos)
	ps.body_set_state(object, PhysicsServer3D.BODY_STATE_TRANSFORM, trans)
	# Create the 3D label
	var label3d = Label3D.new()
	label3d.render_priority = 2         # Higher priority
	# Load and configure the font
	var font = FontFile.new()
	font = Orbitron_Bold # Load the font file

	# Assign the font to the label
	label3d.font = font
	label3d.set_font_size(256)  # Set font size
	label3d.outline_size = 128
	label3d.pixel_size = 0.005
	label3d.uppercase = true #AMAZING. UPPERCASE LOOKS WAY BETTER
	# Offset the labels locally above the sphere node3d
	label3d.position = Vector3(0, 6, 0.01)  # Local space
	
	sphere_node.add_child(label3d)

	#print("label3d parent: ", label3d.get_parent())


	
	# Ensure `sphere_mesh` is valid
	if not VariableDock.sphere_mesh_array[player_number]:
		#print("Error: `sphere_mesh` is not initialized.")
		return
	
	# Create the rendering instance
	var rendering_server_mesh = rs.instance_create2(VariableDock.sphere_mesh_array[player_number].get_rid(), get_world_3d().scenario)
	if not rendering_server_mesh:
		#print("Error: Failed to create rendering server instance.")
		return
	
	rs.instance_set_transform(rendering_server_mesh, trans)
	
	# Debug log
	#print("Sphere mesh RID: ", VariableDock.sphere_mesh_array[player_number].get_rid())
	
	# Create energy outline (lightning bolt)
	var energy_outline = Sprite3D.new()
	energy_outline.texture = preload("res://Assets/player_energy_display_assets/LightningOutline.png")  # Ensure this texture exists
	energy_outline.pixel_size = label3d.pixel_size
	sphere_node.add_child(energy_outline) #both energy textures must be both assigned to same parent, thus being siblings, preventing compounding scaling which misaligns sizes where outline is not same as fill when it shrinks

	# Create energy fill (progress bar)
	var energy_fill = Sprite3D.new()
	energy_fill.texture = preload("res://Assets/player_energy_display_assets/LightningFill.png")
	energy_fill.pixel_size = label3d.pixel_size
	energy_fill.modulate = Color.YELLOW
	sphere_node.add_child(energy_fill) #both energy textures must be both assigned to same parent, thus being siblings, preventing compounding scaling which misaligns sizes where outline is not same as fill when it shrinks

	
	# Store object and mesh for future reference
	#MUST KEEP LABEL 3D AND LABEL3D OUTLINE HERE SO THEY GET DELETED IN CREATE_OBJECT PRIOR TO CREATE_SPHERE THAT WAY PLAYER DEATH WORKS
	objects.append([object, rendering_server_mesh, sphere_node, label3d, energy_outline, energy_fill]) 
	#print("create sphere complete")

func create_objects():
	VariableDock.player_alive[player_number] = 2 #mark that player is now alive again
	#print("creating objects", player_number)
	for obj in objects:
		# Free physics body
		#print("Freeing physics body RID: ", obj[0])
		PhysicsServer3D.free_rid(obj[0])

		# Free sphere_node
		#print("Freeing sphere_node: ", obj[2])
		obj[2].queue_free()

		# Free label3d and label3d_outline
		#print("Freeing label3d: ", obj[3])
		obj[3].queue_free()
		objects.clear()
		objects.erase(obj)
	for i in range(1):
		var pos = update_sphere_positions(i)
		create_sphere(pos)
		#print("creating objects 2")
func create_player_ball_scheduled_for_creation_count():
	# Cap the scheduled creation count to ensure max 9 alive balls
	var current_alive = VariableDock.player_number_of_alive_balls[player_number]
	var max_new = 9 - current_alive  # Allow up to 9 total alive balls
	if max_new <= 0:
		VariableDock.player_ball_scheduled_for_creation_count[player_number] = 0
		return
	
	var actual_create = min(VariableDock.player_ball_scheduled_for_creation_count[player_number], max_new)
	VariableDock.player_ball_scheduled_for_creation_count[player_number] = actual_create
	
	VariableDock.player_alive[player_number] = 2 #mark that player is now alive again
	VariableDock.player_current_lives[player_number] += actual_create #increase player lives equal to amount of newly created balls
	VariableDock.player_number_of_alive_balls[player_number] += actual_create
	for i in range(actual_create):
		var pos = update_sphere_positions(i)
		create_sphere(pos)
		#print("creating additional objects")
	VariableDock.player_ball_scheduled_for_creation_count[player_number] = 0 #set to 0 as now creation has been triggered

func delete_player_ball_scheduled_for_deletion_count():
	var number_to_delete = VariableDock.player_ball_scheduled_for_deletion_count[player_number]
	number_to_delete = round(number_to_delete)
	if number_to_delete <= 0 || objects.size() == 0:
		return
	
	var actual_delete = min(number_to_delete, objects.size())
	var indices = range(objects.size())
	indices.shuffle()
	# Select the first 'actual_delete' indices after shuffling
	var selected_indices = indices.slice(0, actual_delete)
	# Sort selected indices in descending order to avoid shifting issues
	selected_indices.sort()
	selected_indices.reverse()
	
	for idx in selected_indices:
		var obj = objects[idx]
		# Free physics and rendering resources
		PhysicsServer3D.free_rid(obj[0])
		RenderingServer.free_rid(obj[1])
		obj[2].queue_free()
		objects.remove_at(idx)
	
	# Update counters
	VariableDock.player_ball_scheduled_for_deletion_count[player_number] -= actual_delete
	VariableDock.player_number_of_alive_balls[player_number] = objects.size()
	VariableDock.player_current_lives[player_number] -= actual_delete
	if VariableDock.player_current_lives[player_number] < 1:
		VariableDock.player_alive[player_number] = 1
		reset_properties()
	#print("Deleted %d balls for player %d" % [actual_delete, player_number])
	
func update_ui_visibility():
	for i in range(objects.size()):
		var entry = objects[i]
		var label3d = entry[3]
		var energy_outline = entry[4]
		var energy_fill = entry[5]
		label3d.visible = (i == 0)
		energy_outline.visible = (i == 0)
		energy_fill.visible = (i == 0)
func _process(delta):
	if VariableDock.mark_player_connected[player_number] == 2: #only run process if player is marked as connected to help save space
		player_life_update()
		update_ui_visibility()
		player_skin_interface_base_screen.custom_skin_preview_updating(player_number)
		if variable_ready_skin_and_button_defaults == 1 and player_number != -1:
			player_skin_interface_base_screen.game_start_skin_button_defaults(player_number)
			variable_ready_skin_and_button_defaults = 2

		if settings_player_lives != VariableDock.game_start_player_lives:
			#sets player lives, works just fine because ppl cant change player_lives mid game.
			#using settings_player_lives ensures it isnt overwriting the player_lives everytime they change since
			#settings_player_lives stays the same
			VariableDock.player_current_lives[player_number] = VariableDock.game_start_player_lives
			settings_player_lives = VariableDock.game_start_player_lives
			#print("Player lives updated to: ", VariableDock.player_current_lives[player_number])
		if player_number != -1 and VariableDock.game_in_play == 2:
			player_number_based_settings()
			handle_energy_overflow(delta)
			_update_energy_display(delta)
			_update_energy_sync()
			if VariableDock.player_ball_scheduled_for_deletion_count[player_number] > 0:
				delete_player_ball_scheduled_for_deletion_count()
			if VariableDock.player_ball_scheduled_for_creation_count[player_number] > 0:
				#any time game is in play, player is enabled and there are balls scheduled for creation, instantly ceate them
				create_player_ball_scheduled_for_creation_count()
			if player_number < VariableDock.player_buy_transaction_clear_menu_trigger.size():
				if VariableDock.player_buy_transaction_clear_menu_trigger[player_number] == 1:
					VariableDock.player_buy_transaction_clear_menu_trigger[player_number] = 0
					_clear_menu()
			else:
				pass
				#print("Invalid player number or missing data in player_buy_transaction_clear_menu_trigger.")
		if VariableDock.game_in_play == 1 and menu_instance != null: #game is not in play, force clearing menus
			_clear_menu()
			
func player_life_update():
		if VariableDock.game_in_play == 1: #resets player lives when game is not in play
			VariableDock.player_current_lives[player_number] = VariableDock.game_start_player_lives
			#probably not needed cuz it already appends to new player lives on rematch but i guess
			#this is needed to update whenever the lives setting gets changed in the menu that way it updates.
	
func is_dead(): 
	var removal_queue = []
	for obj in objects:
		var body_rid = obj[0]
		var trans = PhysicsServer3D.body_get_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
		if VariableDock.game_in_play == 2 and VariableDock.count == 1: # When there is only 1 player left, delete that player
			VariableDock.player_number_of_winner = player_number
			removal_queue.append(obj)
			VariableDock.player_current_lives[player_number] = 0
			#print("Player life removed via final elimination", VariableDock.player_current_lives[player_number], " player number: ", player_number)
			VariableDock.player_alive[player_number] = 1
			VariableDock.player_number_of_alive_balls[player_number] = 0
			reset_properties()
		elif trans.origin.y < -75:
			removal_queue.append(obj)
			#print("Player death triggered for sphere at Y=", trans.origin.y)
	
	# Process all spheres marked for removal
	for obj in removal_queue:
		VariableDock.player_number_of_alive_balls[player_number] -= 1
		VariableDock.player_current_lives[player_number] -= 1
		#print("Sphere removed. Lives left: ", VariableDock.player_current_lives[player_number], " Alive balls: ", VariableDock.player_number_of_alive_balls[player_number])
		
		PhysicsServer3D.free_rid(obj[0])
		RenderingServer.free_rid(obj[1])
		obj[2].queue_free()
		obj[3].queue_free()
		objects.erase(obj)
	
	# Check if player is dead after processing all removals
	if VariableDock.player_current_lives[player_number] <= 0:
		VariableDock.player_alive[player_number] = 1
		VariableDock.player_number_of_alive_balls[player_number] = 0
		reset_properties()
		#print("Player eliminated. Lives: ", VariableDock.player_current_lives[player_number])
	# Respawn only if no spheres left but lives remain
	elif VariableDock.player_number_of_alive_balls[player_number] == 0 and VariableDock.player_current_lives[player_number] > 0:
		#print("Respawning with ", VariableDock.player_current_lives[player_number], " lives")
		create_objects()
func reset_properties():
	_clear_menu()
	current_energy = 300
	regular_energy_max = 300
	overflow_energy_max = regular_energy_max * 2
	
	### BREAK DEATH REMATCH CODE END

func _physics_process(delta):
	if VariableDock.mark_player_connected[player_number] == 2: #only run physics process if player is marked as connected to help save space
		if player_number != -1 and VariableDock.game_in_play == 1:
			VariableDock.custom_skin_disable_enable_trigger[player_number] = 2 #start  updating for skin viewport mesh after game. Helps with performance.
		if player_number != -1 and VariableDock.game_in_play == 2:
			if VariableDock.player_update_modifier[player_number] == 2:
				#prevent constant radius and height updates which can cause lag. only updates when the variable is 2.
				#so u can set the variable to 2 for the specific player number whenever their value gets updated. and it will update it here so long as game is in play and player number is not -1
				VariableDock.player_update_modifier[player_number] = 1
				obj_shape.radius = .15 + VariableDock.player_radius[player_number] #slightly larger than visual shape radius so it can collide effectively
				VariableDock.sphere_mesh_array[player_number].radius = VariableDock.player_radius[player_number]
				VariableDock.sphere_mesh_array[player_number].height = VariableDock.player_radius[player_number] * 2
				# Set the radius of the collision shape instantly so that it updates whenever it chaanges				#these values get cleared / reset every rematch via variable dock
				#only update if player is alive and game is currently ongoing to prevent issue of trying to modify radius of destroyed objects.
				#print("VariableDock.sphere_mesh_array[player_number].height: ", VariableDock.sphere_mesh_array[player_number].height, "VariableDock.sphere_mesh_array[player_number].radius: ", VariableDock.sphere_mesh_array[player_number].radius, "VariableDock.player_update_modifier[player_number]: ", VariableDock.player_update_modifier[player_number])
			VariableDock.custom_skin_disable_enable_trigger[player_number] = 1 #stops updating for skin viewport mesh mid game. Helps with performance.
			# Replace the existing loop in _physics_process with:
			var positions = []
			for obj in objects:
				var body_rid = obj[0]
				var trans = PhysicsServer3D.body_get_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
				positions.append(trans.origin)
			VariableDock.player_transform_position[player_number] = positions #stores muiltple positiosn for each player body
			if VariableDock.initial_player_creation[player_number] == 2:
				VariableDock.initial_player_creation[player_number] = 1 #ensures player does not get created a second time
				obj_shape.radius = .1 + VariableDock.player_radius[player_number] #slightly larger than visual shape radius so it can collide effectively
				VariableDock.sphere_mesh_array[player_number].radius = VariableDock.player_radius[player_number]
				VariableDock.sphere_mesh_array[player_number].height = VariableDock.player_radius[player_number] * 2
				create_objects()
				# Create a Timer node for exit timeout on menus
				menu_timer = Timer.new()
				menu_timer.wait_time = 5.0  # Set the timer to 5 seconds
				menu_timer.one_shot = true  # Ensure it stops after timeout
				add_child(menu_timer)
				# Connect the timeout signal to _clear_menu
				menu_timer.connect("timeout", Callable(self, "_clear_menu"))
				
				# Create a Timer node for stealth
				stealth_timer = Timer.new()
				stealth_timer.wait_time = 1.0  # Set the timer to 5 seconds
				stealth_timer.one_shot = true  # Ensure it stops after timeout
				add_child(stealth_timer)
				# Connect the timeout signal to stealth disable
				stealth_timer.connect("timeout", Callable(self, "_stealth_disable"))
				#print("Full player creation triggered")
			# Check if the player is "dead" based on their position
			is_dead()
		if player_number != -1 and VariableDock.game_in_play == 2:

				if menu_instance:
					# Get the player's position
					#a bit complex cuz taking that 3d player coordinate and trying to convert it to a 2d coordinate that can be
					#applied to the 2d player menu
					for entry in objects:
						var physics_object = entry[0]
						var player_transform = PhysicsServer3D.body_get_state(physics_object, PhysicsServer3D.BODY_STATE_TRANSFORM)
						var player_position = player_transform.origin

						# Convert 3D position to 2D screen coordinates
						var viewport = get_viewport()
						var screen_position = viewport.get_camera_3d().unproject_position(player_position)

						# Update menu position
						menu_instance.position = screen_position
						break  # Stop after first player object found

				for entry in objects:
					var physics_object = entry[0]  # Physics object RID
					var rendering_mesh_rid = entry[1]  # RenderingServer instance RID
					var sphere_node = entry[2]    # Node3D parent of the labels
					
					# Fetch the physics body's current transform
					var physics_transform = PhysicsServer3D.body_get_state(physics_object, PhysicsServer3D.BODY_STATE_TRANSFORM)
					
					# Synchronize both the sphere_node and the visual mesh
					sphere_node.global_transform = physics_transform
					RenderingServer.instance_set_transform(rendering_mesh_rid, physics_transform)
					# Maintain fixed rotation for labels
					sphere_node.rotation_degrees = Vector3(-90, -90, 0)
					var camera_height = top_down_camera_3d.global_transform.origin.y
					var scale_factor = clamp(camera_height / 50.0, 1, 30.0)  # Adjust 10.0 based on your needs
					
					# Scale labels
					sphere_node.scale = Vector3(scale_factor, scale_factor, scale_factor)
					if 1 <= scale_factor and scale_factor < 1.75:
						x_offset_factor = scale_factor * 3 - VariableDock.player_radius[player_number] + 2
					if 1.75 <= scale_factor and scale_factor < 3:
						x_offset_factor = scale_factor * 4 - VariableDock.player_radius[player_number] + 2
					if scale_factor >= 3:
						x_offset_factor = scale_factor * 4.5 - VariableDock.player_radius[player_number] + 2
					# Adjust position to move it back on X axis as the camera goes higher
					var current_position = sphere_node.global_transform.origin
					sphere_node.global_transform.origin = current_position - Vector3(x_offset_factor, 0, 0)
					
				# Inside _physics_process(delta):
				check_rapid_input("player_%d_move_forward" % player_number, Vector3(1 * VariableDock.player_dash_force_multiplier + VariableDock.player_radius[player_number], 0, 0))
				check_rapid_input("player_%d_move_backward" % player_number, Vector3(-1 * VariableDock.player_dash_force_multiplier + VariableDock.player_radius[player_number], 0, 0))
				check_rapid_input("player_%d_move_right" % player_number, Vector3(0, 0, 1 * VariableDock.player_dash_force_multiplier + VariableDock.player_radius[player_number]))
				check_rapid_input("player_%d_move_left" % player_number, Vector3(0, 0, -1 * VariableDock.player_dash_force_multiplier + VariableDock.player_radius[player_number]))
				check_rapid_input("player_%d_jump" % player_number, Vector3(0, 25 * VariableDock.base_empowered_jump_modifier_multiplier_all_players + VariableDock.player_radius[player_number], 0))
				##print("On ground: ", is_on_ground, ", Available jumps: ", available_jumps)
				
				for obj in objects:
					var body_rid = obj[0]
					if check_on_ground(body_rid):
						reset_jumps()
					if check_on_energy_orb(body_rid):
						pass
						#print("Current_energy increase triggered via energy_orb", current_energy)
				if Input.is_action_pressed("player_%d_move_right" % player_number) or Input.is_action_pressed("player_%d_move_left" % player_number):
					for obj in objects:
						var body_rid = obj[0]
						
						# Get the current linear velocity
						var linear_velocity = PhysicsServer3D.body_get_state(body_rid, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
						
						# Determine direction: positive for right, negative for left
						var direction = 1 if Input.is_action_pressed("player_%d_move_right" % player_number) else -1
						
						var radius_factor = VariableDock.player_radius[player_number] * 0.85 #need more force to move higher mass/radius objects. so speed scales with radius
						var impulse_strength = direction * speed_modifier * radius_factor * linear_velocity.length()#the if statements are to help turn around as to turn around must overcome all the previously built up force in opposite drirection
						
						# Apply the impulse along the X-axis
						PhysicsServer3D.body_apply_force(body_rid, Vector3(0, 0, impulse_strength))
						# Calculate and apply torque for rotation
						# Debugging output
						#print("Direction:", direction)
						#print("Impulse strength:", impulse_strength)
						#print("Linear velocity after movement:", linear_velocity)
				if Input.is_action_pressed("player_%d_move_forward" % player_number) or Input.is_action_pressed("player_%d_move_backward" % player_number):
					for obj in objects:
						var body_rid = obj[0]
						
						# Get the current linear velocity
						var linear_velocity = PhysicsServer3D.body_get_state(body_rid, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
						
						# Determine direction: positive for right, negative for left
						var direction = 1 if Input.is_action_pressed("player_%d_move_forward" % player_number) else -1
						
						# Calculate the impulse strength
						#the if statements are to help turn around as to turn around must overcome all the previously built up force in opposite drirection
						
						var radius_factor = VariableDock.player_radius[player_number] * 0.85 #need more force to move higher mass/radius objects. so speed scales with radius
						var impulse_strength = direction * speed_modifier * radius_factor * linear_velocity.length()#the if statements are to help turn around as to turn around must overcome all the previously built up force in opposite drirection
						
						# Apply the impulse along the X-axis
						PhysicsServer3D.body_apply_force(body_rid, Vector3(impulse_strength, 0, 0))

						# Debugging output
						#print("Direction:", direction)
						#print("Impulse strength:", impulse_strength)
						#print("Linear velocity after movement:", linear_velocity)

				if Input.is_action_just_pressed("player_%d_jump" % player_number) and available_jumps > 0:
					for obj in objects:
						var body_rid = obj[0]
						# Get the current linear velocity
						available_jumps -= 1
						# Get the current velocity
						var linear_velocity = PhysicsServer3D.body_get_state(body_rid, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
						var impulse_strength = VariableDock.base_jump_modifier_all_players
						# Override the Y velocity for a consistent jump height

						# Set the velocity directly (mass-independent)
						# Update the Y component while keeping X and Z the same
						#it only updates the Y component (current_velocity.y = impulse_strength). Thats where it actually gets updated
						# Set the updated velocity back to the body. This is just ensuring everything works properly.
						PhysicsServer3D.body_apply_force(body_rid, Vector3(0, impulse_strength, 0))
						# Debugging output
						#print("Impulse strength:", VariableDock.base_jump_modifier_all_players)
				for obj in objects:
					#mass constantly updating via physics process so long as game is playing and player number is not -1
					var body_rid = obj[0]
					# Get the current linear velocity
					var linear_velocity = PhysicsServer3D.body_get_state(body_rid, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY)
					if linear_velocity.length() > 1:
						#print(linear_velocity.length(), "linear_velocity.length()")
						var mass_calculation = .25 + linear_velocity.length() * VariableDock.player_radius[player_number] * .1 #.25 is base mass #raise .2 multiplier for player_radius and speed to impact mass more
						##print("mass calculation: ",mass_calculation)
						PhysicsServer3D.body_set_param(body_rid, PhysicsServer3D.BODY_PARAM_MASS, mass_calculation)
					if linear_velocity.length() <= 1:
						PhysicsServer3D.body_set_param(body_rid, PhysicsServer3D.BODY_PARAM_MASS, .25) #.25 is base mass
						#ESSENTIAL NOTE DO NOT REMOVE. you must set a mass and bounce even if there is no linear velocity
						#otherwise balls go crazy if anything hits them because the ball hitting them has mass and the ball
						#recieving the hit has literally 0 mass.
					
func action_rapid_input_set():
	actions = [
						"player_%d_move_forward" % player_number,
						"player_%d_move_backward" % player_number,
						"player_%d_move_right" % player_number,
						"player_%d_move_left" % player_number,
						"player_%d_jump" % player_number
				]
	#print("action destiny display.", actions)
	# Initialize input_timestamps for each action
	for action in actions:
		if not input_timestamps.has(action):
			input_timestamps[action] = []
	#print("Action keys initialized: ", actions)

func _rally_ability():
	if objects.size() < 1:
		return  # No spheres to rally
	
	# Get the transform of the first sphere (index 0)
	var first_sphere_rid = objects[0][0]
	var first_transform = PhysicsServer3D.body_get_state(first_sphere_rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
	
	# Move all other spheres to the first sphere's position and reset velocities
	for i in range(1, objects.size()):
		var sphere_rid = objects[i][0]
		PhysicsServer3D.body_set_state(sphere_rid, PhysicsServer3D.BODY_STATE_TRANSFORM, first_transform)
		# Reset velocities to prevent movement after teleport
		PhysicsServer3D.body_set_state(sphere_rid, PhysicsServer3D.BODY_STATE_LINEAR_VELOCITY, Vector3.ZERO)
		PhysicsServer3D.body_set_state(sphere_rid, PhysicsServer3D.BODY_STATE_ANGULAR_VELOCITY, Vector3.ZERO)
		current_energy -= 25
	#print("Rally ability activated for player %d" % player_number)

func _input(event):
	if event.is_action_pressed("player_%d_rally" % player_number) and VariableDock.game_in_play == 2 and player_number != -1 and objects.size() > 1:
		_rally_ability()
	if event.is_action_pressed("player_%d_stealth" % player_number) and VariableDock.stealth_enabled == 1 and player_number != -1 and VariableDock.game_in_play == 2 and current_energy >= 100:
		#print(VariableDock.sphere_mesh_array[player_number].material, "Pre stealth change material sphere_mesh.material")
		last_material = VariableDock.sphere_mesh_array[player_number].material
		VariableDock.sphere_mesh_array[player_number].material = VariableDock.TRANSPARENT_MATERIAL
		current_energy -= 100
		for entry in objects:
			var label = entry[3]    # Node3D parent of the labels
			var energy_outline = entry[4]    # Node3D parent of the labels
			var energy_fill = entry[5]    # Node3D parent of the labels
			label.visible = false  # hides the label
			energy_outline.visible = false  # hides the label
			energy_fill.visible = false  # hides the label

		if stealth_timer.is_stopped():
			stealth_timer.start()
		else:
			stealth_timer.stop()
			stealth_timer.start()
		#material
	# In your input event function
	if event.is_action_pressed("connect_controller") and controller_number != -1:
		var device_check = event.device  # Get the device ID from the event
		#print(device_check, " device check. ", controller_number, "controller_number")
		if device_check == controller_number:
			if player_number == -1:
				for player in range(8): #Keep in mind it stops right before n, which is 8 here. so this gives max player number for controllers at 7. preventing player number overlap with keyboard which has player number 8 and 9
					if VariableDock.enable_player[player] == 1:
						# Assign the device to this player
						player_number = player
						VariableDock.enable_player[player] = 2  # Mark as occupied
						VariableDock.mark_player_connected[player] = 2 # A SEPERATE MARK FROM ENABLE_PLAYER FOR SHOWING PLAYER IS CURRENTLY CONNECTED. USED TO MAKE SURE THE SKIN DISPLAY WORKS EVEN WHEN PLAYER IS DEAD. AS PREVIOUSLY USING ENABLE_PLAYER WHEN PLAYER IS DEAD IT WOULDNT SHOW SKINS IN MAIN MENU WHICH IS A ISSUE
						action_rapid_input_set()
						#print("Assigned Device %d to Player %d." % [device_check, player])
						break
					else:
						pass
						#print("No available player slots for Device %d." % device_check)
	if event.is_action_pressed("connect_keyboard_player_9"):
		if VariableDock.keyboard_player_9 == 1 and keyboard_connect_tracker == 0 and controller_number == -1: #ensures via total_connected_keyboards that last 1 will trigger on 1, so i will have 2 connected keyboards
			#Variable Dock value to track total connected keyboards
			keyboard_connect_tracker = 1 #prevents player number overlaps from same script connecting twice,
			VariableDock.keyboard_player_9 += 1
			player_number = 9
			VariableDock.enable_player[player_number] = 2
			VariableDock.mark_player_connected[player_number] = 2 # A SEPERATE MARK FROM ENABLE_PLAYER FOR SHOWING PLAYER IS CURRENTLY CONNECTED. USED TO MAKE SURE THE SKIN DISPLAY WORKS EVEN WHEN PLAYER IS DEAD. AS PREVIOUSLY USING ENABLE_PLAYER WHEN PLAYER IS DEAD IT WOULDNT SHOW SKINS IN MAIN MENU WHICH IS A ISSUE
			action_rapid_input_set()
			#print("connect keyboard player: ", player_number)

	if event.is_action_pressed("connect_keyboard_player_8"):
		if VariableDock.keyboard_player_8 == 1 and keyboard_connect_tracker == 0 and controller_number == -1: #ensures via total_connected_keyboards that last 1 will trigger on 1, so i will have 2 connected keyboards
			#Variable Dock value to track total connected keyboards
			keyboard_connect_tracker = 1 #prevents player number overlaps from same script connecting twice,
			VariableDock.keyboard_player_8 += 1
			player_number = 8
			VariableDock.enable_player[player_number] = 2
			VariableDock.mark_player_connected[player_number] = 2 # A SEPERATE MARK FROM ENABLE_PLAYER FOR SHOWING PLAYER IS CURRENTLY CONNECTED. USED TO MAKE SURE THE SKIN DISPLAY WORKS EVEN WHEN PLAYER IS DEAD. AS PREVIOUSLY USING ENABLE_PLAYER WHEN PLAYER IS DEAD IT WOULDNT SHOW SKINS IN MAIN MENU WHICH IS A ISSUE
			action_rapid_input_set()
			#print("connect keyboard player: ", player_number)
			
	if player_number != -1 and VariableDock.game_in_play == 2:
		if event.is_action_pressed("player_%d_cycle_trigger_assist_shift" % player_number):
			shift_pressed = true
		elif event.is_action_released("player_%d_cycle_trigger_assist_shift" % player_number):
			shift_pressed = false
		if event.is_action_pressed("player_%d_cycle_mode" % player_number):
				# Reset the timer
			if menu_timer.is_stopped():
				menu_timer.start()
			else:
				menu_timer.stop()
				menu_timer.start()
		if not shift_pressed and event.is_action_pressed("player_%d_cycle_mode" % player_number):  # Pressing E key cycles modes

			if menu_instance == null:
				_show_primary_menu()  # Open the menu if it's not visible
				selected_index = 1  # Start with the first option highlighted
				_update_highlight()  # Highlight the first option
			else:
				selected_index += 2  # Move to the next option. for some reason its gotta be 2 i think the even numbers
				#represent labels or some other shape. only odd numbers represent triangles or something.
				if selected_index >= buttons.size():
					selected_index = 1  # Wrap around to the first option
				_update_highlight()  # Update the highlight
		elif event.is_action_pressed("player_%d_cycle_mode" % player_number) and shift_pressed and menu_instance:
			_activate_selected()


func handle_energy_overflow(delta):
	time_accumulator += delta
	if current_energy > overflow_energy_max:
		#print("overflow_energy_max updating current_energy to", overflow_energy_max)
		current_energy = overflow_energy_max
	if time_accumulator >= 1.0:  # 1 second has passed
		time_accumulator = 0.0
		if VariableDock.player_radius[player_number] < 1.5: #important it cannot have less than or equal to otherwise it glitches. u seemake player gradually bigger at sacrifice of energy
			if current_energy > 0:
				var radius_increase = .3
				current_energy -= 30 / VariableDock.player_radius[player_number]
				if 1.2 < VariableDock.player_radius[player_number] and VariableDock.player_radius[player_number] <= 1.5:
					VariableDock.player_radius[player_number] = 1.5 # makes sure it always goes back to default size
					obj_shape.radius = .15 + VariableDock.player_radius[player_number]
				else:
					VariableDock.player_radius[player_number] = radius_increase + VariableDock.player_radius[player_number]
				VariableDock.sphere_mesh_array[player_number].radius = VariableDock.player_radius[player_number]
				VariableDock.sphere_mesh_array[player_number].height = VariableDock.player_radius[player_number] * 2
				obj_shape.radius = .15 + VariableDock.player_radius[player_number]
			else: #important it only triggers when radius is below 1.5 and current energy 0 or lower
				#pay a huge price for running out of energy while too small.
				#set all of the players platforms to neutral ownership. gotta call a function in sumo ring
				sumo_section.reset_player_platforms_to_neutral(player_number)
				current_energy = 1 #to prevent continual triggers
				VariableDock.player_radius[player_number] = 1.5
				VariableDock.sphere_mesh_array[player_number].radius = VariableDock.player_radius[player_number]
				VariableDock.sphere_mesh_array[player_number].height = VariableDock.player_radius[player_number] * 2
				obj_shape.radius = .15 + VariableDock.player_radius[player_number]
		if VariableDock.player_radius[player_number] > 4: #Make player smaller gradually if too big and give energy proportional to size prior to each reduction
			if VariableDock.player_radius[player_number] > 10:
				#faster desize if large but same proportional energy gain
				current_energy += VariableDock.player_radius[player_number] * 45 #adjust 15 as needed
				VariableDock.player_radius[player_number] = .7 * VariableDock.player_radius[player_number] #.9 is radius drain rate can lower or raise it if u want
				VariableDock.sphere_mesh_array[player_number].radius = VariableDock.player_radius[player_number]
				VariableDock.sphere_mesh_array[player_number].height = VariableDock.player_radius[player_number] * 2
				obj_shape.radius = .15 + VariableDock.player_radius[player_number]
			else:
				current_energy += VariableDock.player_radius[player_number] * 15 #adjust 15 as needed
				VariableDock.player_radius[player_number] = .9 * VariableDock.player_radius[player_number] #.9 is radius drain rate can lower or raise it if u want
				VariableDock.sphere_mesh_array[player_number].radius = VariableDock.player_radius[player_number]
				VariableDock.sphere_mesh_array[player_number].height = VariableDock.player_radius[player_number] * 2
				obj_shape.radius = .15 + VariableDock.player_radius[player_number] #sets collision shape radius
		if VariableDock.player_radius[player_number] > 20:
			VariableDock.player_radius[player_number] = 20 #hard cap on radius size to prevent edge situations that ruin game like getting two crazy multipliers at once which makes player too big for camera to even adjust to see
			VariableDock.sphere_mesh_array[player_number].radius = VariableDock.player_radius[player_number]
			VariableDock.sphere_mesh_array[player_number].height = VariableDock.player_radius[player_number] * 2
			obj_shape.radius = .15 + VariableDock.player_radius[player_number]
		if current_energy > regular_energy_max * 1.1:
			overflow_energy_loss_per_second = current_energy * 0.05
			current_energy -= overflow_energy_loss_per_second
			#print("Energy reduced, current energy: ", current_energy)
		if current_energy <= regular_energy_max * 1.1 and current_energy > regular_energy_max:
			#makes sure players dont get left with  a weird number at end of overflow. this way its at their max.. espescially important
			# early game when the players max is 100 so the energy loss needs to stop on 100.
			current_energy = regular_energy_max
			#print("Energy set to max energy: ", current_energy)
		if current_energy <= 0:
			current_energy = 0
func player_number_based_settings():
	for entry in objects: #CONSTATLY UPDATE TEXT IN CASE PLAYER TEXT CHANGES
		var label3d = entry[3]    # Node3D parent of the labels
		# Fetch the physics body's current transform
		if player_number == 1:
			label3d.text = VariableDock.player_1_name_text
		if player_number == 2:
			label3d.text = VariableDock.player_2_name_text
		if player_number == 3:
			label3d.text = VariableDock.player_3_name_text
		if player_number == 4:
			label3d.text = VariableDock.player_4_name_text
		if player_number == 5:
			label3d.text = VariableDock.player_5_name_text
		if player_number == 6:
			label3d.text = VariableDock.player_6_name_text
		if player_number == 7:
			label3d.text = VariableDock.player_7_name_text
		if player_number == 8:
			label3d.text = VariableDock.player_8_name_text
		if player_number == 9:
			label3d.text = VariableDock.player_9_name_text
		if player_number == 0:
			label3d.text = VariableDock.player_10_name_text
#allows for easy player number based settings so i dont have to constantly manually update color, material etc everytime i copy script over


func update_sphere_positions(index: int) -> Vector3:
	var base_capacity = 6
	var ring_radius_increment = 4
	var radius = 4
	var current_ring = 0
	var spheres_in_current_ring = 0
	var capacity_increment = 6  # Determines how circular the formation is; 6 is a good default
	var current_ring_capacity = base_capacity

	for i in range(index + 1):
		if spheres_in_current_ring >= current_ring_capacity:
			current_ring += 1
			current_ring_capacity = base_capacity + current_ring * capacity_increment
			spheres_in_current_ring = 0

		spheres_in_current_ring += 1

	var current_radius = radius if current_ring == 0 else radius + current_ring * ring_radius_increment
	var angle = (spheres_in_current_ring - 1) * TAU / current_ring_capacity
	return Vector3(current_radius * cos(angle), 3, current_radius * sin(angle))



func check_rapid_input(action: String, force: Vector3):
		if not input_timestamps.has(action):
			#print("Action key missing: ", action)
			return  # Exit the function early because no timestamp innitialized
		if  player_number != -1 and 100 <= current_energy and Input.is_action_just_pressed(action):
			# Record the timestamp (ensure proper access to OS)
			input_timestamps[action].append(Time.get_ticks_msec() / 1000.0)  # Convert to seconds

			# Remove timestamps older than the input window
			input_timestamps[action] = input_timestamps[action].filter(
				func(time):
					return Time.get_ticks_msec() / 1000.0 - time <= input_window
			)
			# Apply force if there are at least three inputs within the window
			if input_timestamps[action].size() >= 3:
				current_energy -= 100
				if action == "player_%d_jump" % player_number:
					emit_dust_effect()
				if action != "player_%d_jump" % player_number:
					#print("turbo triggered")
					emit_turbo_effect(action)  # Add this line
				for obj in objects:
					var body_rid = obj[0]
					PhysicsServer3D.body_apply_impulse(body_rid, force)
func emit_turbo_effect(action: String):
	if objects.is_empty():
		return
	
	var turbo_instance = TURBO_BUBBLE.instantiate()
	var sphere_node = objects[0][2]  # Get the first sphere's Node3D
	
	var offset = Vector3.ZERO
	var direction = Vector3.ZERO  # Initialize direction vector
	
	if action == "player_%d_move_forward" % player_number:
			offset = Vector3(0, 0, 2.5)  # Local (behind player)
			direction = Vector3(0, -1, 0)  # Emit backward (Y-)
	elif action == "player_%d_move_backward" % player_number:
			offset = Vector3(0, 6, 2.5)  # Local (behind player)
			direction = Vector3(0, 1, 0)   # Emit forward (Y+)
	elif action == "player_%d_move_right" % player_number:
			offset = Vector3(-2.5, 2.5, 0) # Local (left side)
			direction = Vector3(-1, 0, 0)   # Emit left (X-)
	elif action == "player_%d_move_left" % player_number:
			offset = Vector3(2.5, 2.5, 0)  # Local (right side)
			direction = Vector3(1, 0, 0)    # Emit right (X+)
			
	turbo_instance.position = offset
	sphere_node.add_child(turbo_instance)
	
	var particles = turbo_instance.get_node("GPUParticles3D")
	if particles:
		# Set particle direction in process material
		var material = particles.process_material
		if material:
			# Create unique material instance for this emission
			var new_material = material.duplicate()
			new_material.direction = direction
			particles.process_material = new_material
		
		# Set particle mesh material to match player's sphere
		var particle_mesh: Mesh = particles.get_draw_pass_mesh(0)
		var new_mesh = particle_mesh.duplicate()
		new_mesh.material = VariableDock.sphere_mesh_array[player_number].material
		particles.set_draw_pass_mesh(0, new_mesh)
		particles.emitting = true
		particles.lifetime = 1.25
	else:
		pass
		#print("GPUParticles3D node not found in TURBO_BUBBLE scene")

func emit_dust_effect():
	for obj in objects:
		var body_rid = obj[0]
		var trans = PhysicsServer3D.body_get_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
		var dust = DUST_CLOUD.instantiate()
		get_parent().add_child(dust)  # Add to the scene tree
		dust.global_transform.origin = trans.origin
		var particles = dust.get_node("GPUParticles3D")  # Replace with your actual node name
		particles.emitting = true
		# Set particle mesh material to match player's sphere material
		var particle_mesh: Mesh = particles.get_draw_pass_mesh(0)
		var new_mesh = particle_mesh.duplicate()
		new_mesh.material = VariableDock.sphere_mesh_array[player_number].material
		particles.set_draw_pass_mesh(0, new_mesh)
		
		# Start emission
		particles.emitting = true
		

# Revised energy orb detection using shape query
func check_on_energy_orb(body_rid: RID) -> bool:
	var space_state = PhysicsServer3D.space_get_direct_state(get_world_3d().space)
	if not space_state:
		return false

	var body_transform = PhysicsServer3D.body_get_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
	var origin = body_transform.origin
	
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape_rid = obj_shape.get_rid()
	params.transform = Transform3D(Basis.IDENTITY, origin)
	params.collision_mask = energy_orb_layer
	
	var results = space_state.intersect_shape(params)
	var collected = false
	
	for result in results:
		var collider = result.collider
		if collider.is_in_group("energy_orbs"):
			collider.queue_free()
			current_energy += 100
			collected = true
		elif collider.is_in_group("math_modifiers"):
			sumo_section.apply_modifier_to_player(player_number, collider)
			collider.queue_free()
			collected = true
	
	return collected

func check_on_ground(body_rid: RID) -> bool:
	var space_state = PhysicsServer3D.space_get_direct_state(get_world_3d().space)
	if not space_state:
		return false

	var body_transform = PhysicsServer3D.body_get_state(body_rid, PhysicsServer3D.BODY_STATE_TRANSFORM)
	var origin = body_transform.origin
	
	var params = PhysicsShapeQueryParameters3D.new()
	params.shape_rid = obj_shape.get_rid()
	params.transform = Transform3D(Basis.IDENTITY, origin - Vector3(0, VariableDock.sphere_mesh_array[player_number].radius, 0))
	params.collision_mask = ground_layer
	
	var results = space_state.intersect_shape(params)
	
	for result in results:
		var collider = result.collider
		# Add null check first
		if collider and collider.is_in_group("ground"):
			# Extra safety check for sumo_section
			if sumo_section and sumo_section.has_method("change_material"):
				sumo_section.call("change_material", collider, player_number)
			return true
	
	return false


func _exit_tree():
		for obj in objects:
			PhysicsServer3D.free_rid(obj[0])
			RenderingServer.free_rid(obj[1])
		for child in get_children():
				child.queue_free()
func reset_jumps():
		available_jumps = max_jumps
	##print("Jumps reset to: ", available_jumps)

func _stealth_disable():
		#sets material back to the normal one
		#triggers when stealth timer runs out
		VariableDock.sphere_mesh_array[player_number].material = last_material
		for entry in objects:
			var label = entry[3]    # Node3D parent of the labels
			var energy_outline = entry[4]    # Node3D parent of the labels
			var energy_fill = entry[5]    # Node3D parent of the labels
			label.visible = true  # shows the label
			energy_outline.visible = true  # shows the label
			energy_fill.visible = true  # shows the label


func _update_highlight():
	for i in range(buttons.size()):
		var button_node = buttons[i]
		if button_node.has_meta("triangle"):  # Highlight triangles
			var triangle = button_node.get_child(0) as Polygon2D
			if i == selected_index:
				triangle.color = Color(1.0, 0.8, 0.0)  # Highlight color (yellow)
			else:
				triangle.color = Color(0.0, 0.6, 0.8)  # Default color (cyan)
		# No need for "Button" logic anymore since we're only using triangles now

func _show_burn_trigger():
	if current_energy >= 100:
		current_energy -= 100
		sumo_section.trigger_platform_destruction_burn.bind(sumo_section.player_platforms.get(player_number, []), player_number).call()  # Added .call() to execute the bound method



func _show_primary_menu():
	var owned_platforms = sumo_section.player_platforms.get(player_number, [])
	if owned_platforms.is_empty():
		#print("No platforms owned - cannot show menu")
		return
	_clear_menu()
	_create_menu()

	var menu_options = [
		{"text": "BUY", "action": Callable(self, "_show_buy_menu")},
		{"text": "SELL", "action": Callable(self, "_show_sell_menu")},
		{"text": "BURN", "action": Callable(self, "_show_burn_trigger")},
		{"text": "MOVE", "action": Callable(self, "_show_move_menu")},
	]

	var triangle_width = 80  # Width of each triangle
	for i in range(menu_options.size()):
		var position = Vector2(i * triangle_width * 0.5, 0)  # X-offset for spacing
		var flip = i % 2 == 1  # Alternate triangle flip
		buttons.append(_create_triangle_button(menu_options[i]["text"], position, flip, menu_options[i]["action"]))

func _create_triangle_button(
		text: String, 
		position: Vector2, 
		flip: bool, 
		action: Callable, 
		color: Color = Color(0.0, 0.6, 0.8)  # Default cyan
	):
	var button_node = Control.new()
	button_node.position = position
	menu_instance.add_child(button_node)

	var triangle = Polygon2D.new()
	var triangle_shape = _generate_triangle_shape(flip, 1, 1)
	triangle.polygon = triangle_shape
	triangle.color = color  # Use the color parameter
	button_node.add_child(triangle)

	_add_triangle_outline(button_node, triangle_shape)

	var vertical_offset = -triangle_shape[0].y + 1 if flip else triangle_shape[0].y + 55
	var label = Label.new()
	label.text = text
	label.position = Vector2(0, vertical_offset)
	button_node.add_child(label)
	_center_label_horizontally(label, triangle_shape)

	# Store the Callable in metadata
	button_node.set_meta("action", action)
	button_node.set_meta("triangle", true)

	buttons.append(button_node)

	return button_node

	
func _show_move_menu():
	selected_index = 1 #RESET OPTION TO SELECT FIRST OPTION ON NEW MENU
	_clear_menu()
	_create_menu()
	var options = [
			{"text": "DROP", "action": Callable(self, "_move_menu_energy_reduction_move_trigger").bind(1)},
			{"text": "RISE", "action": Callable(self, "_move_menu_energy_reduction_move_trigger").bind(2)},
			{"text": "X° -", "action": Callable(self, "_move_menu_energy_reduction_move_trigger").bind(3)},
			{"text": "X° +", "action": Callable(self, "_move_menu_energy_reduction_move_trigger").bind(4)},
			{"text": "Y° -", "action": Callable(self, "_move_menu_energy_reduction_move_trigger").bind(5)},
			{"text": "Y° +", "action": Callable(self, "_move_menu_energy_reduction_move_trigger").bind(6)},
			{"text": "Z° -", "action": Callable(self, "_move_menu_energy_reduction_move_trigger").bind(7)},
			{"text": "Z° +", "action": Callable(self, "_move_menu_energy_reduction_move_trigger").bind(8)}
	]
	_populate_submenu(options)
	_update_highlight()

func _move_menu_energy_reduction_move_trigger(move_option_id):
	if current_energy >= 100:
		current_energy -= 100
		match move_option_id:
			1:
				sumo_section._adjust_platform_height(sumo_section.player_platforms.get(player_number, []), -3)
			2:
				sumo_section._adjust_platform_height(sumo_section.player_platforms.get(player_number, []), 3)
			3:
				sumo_section._rotate_platform(sumo_section.player_platforms.get(player_number, []), Vector3(-1, 0, 0))
			4:
				sumo_section._rotate_platform(sumo_section.player_platforms.get(player_number, []), Vector3(1, 0, 0))
			5:
				sumo_section._rotate_platform(sumo_section.player_platforms.get(player_number, []), Vector3(0, -1, 0))
			6:
				sumo_section._rotate_platform(sumo_section.player_platforms.get(player_number, []), Vector3(0, 1, 0))
			7:
				sumo_section._rotate_platform(sumo_section.player_platforms.get(player_number, []), Vector3(0, 0, -1))
			8:
				sumo_section._rotate_platform(sumo_section.player_platforms.get(player_number, []), Vector3(0, 0, 1))
func _create_option_button(text: String, position: Vector2, action: Callable):
	var button_node = Button.new()
	button_node.text = text
	button_node.position = position  # Use position instead of rect_position
	button_node.size_flags_horizontal = Control.SIZE_EXPAND_FILL  # Optional: For better layout handling
	button_node.size_flags_vertical = Control.SIZE_FILL  # Optional: Adjust for layout as needed
	menu_instance.add_child(button_node)

	# Store the Callable in the button's metadata
	button_node.set_meta("action", action)

	# Connect the "pressed" signal directly to a callable that references this function
	button_node.connect("pressed", Callable(self, "_on_submenu_button_pressed").bind(button_node))
	return button_node




func _on_submenu_button_pressed(button_node: Button):
	# Retrieve the Callable from the button's metadata
	var action: Callable = button_node.get_meta("action")
	if action and action.is_valid():
		action.call()

func _center_label_horizontally(label: Label, triangle_shape: PackedVector2Array):
	var base_mid_x = (triangle_shape[1].x + triangle_shape[2].x) / 2
	var half_label_width = label.get_minimum_size().x / 2
	label.position.x = base_mid_x - half_label_width

func _add_triangle_outline(parent_node: Node, triangle_points: PackedVector2Array):
	var outline_color = Color(0, 0, 0)
	var outline_width = 4.0
	for i in range(triangle_points.size()):
		var start_point = triangle_points[i]
		var end_point = triangle_points[(i + 1) % triangle_points.size()]
		var line = Line2D.new()
		line.points = PackedVector2Array([start_point, end_point])
		line.width = outline_width
		line.default_color = outline_color
		parent_node.add_child(line)

func _generate_triangle_shape(flip: bool, scale_width: float, scale_height: float) -> PackedVector2Array:
	var triangle_width = 80 * scale_width
	var triangle_height = 40 * scale_height

	var triangle_points = PackedVector2Array()
	triangle_points.append(Vector2(0, -triangle_height))
	triangle_points.append(Vector2(-triangle_width / 2, triangle_height))
	triangle_points.append(Vector2(triangle_width / 2, triangle_height))

	if flip:
		for i in range(triangle_points.size()):
			triangle_points[i].y = -triangle_points[i].y

	return triangle_points

func _clear_menu():
	if menu_instance:
		menu_instance.queue_free()
	if canvas_layer:
		canvas_layer.queue_free()
	buttons.clear()

# In player.gd - Add debug visualization
func _create_menu():
	canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 100  # Ensure it's on top
	add_child(canvas_layer)
	
	menu_instance = Control.new()
	menu_instance.name = "PlayerMenu"
	
	canvas_layer.add_child(menu_instance)
	#print("Menu created at path: ", menu_instance.get_path())
# In player.gd - Add validation to menu actions
# Add to _activate_selected():
func _activate_selected():
	if selected_index >= buttons.size():
		return
	
	var button_node = buttons[selected_index]
	if !button_node.has_meta("action"):
		#printerr("No action found for button")
		return
	
	var action = button_node.get_meta("action")
	if !action.is_valid():
		#printerr("Invalid action Callable")
		return
	
	# Verify platform ownership
	if action.get_method() == "trigger_platform_destruction_burn":
		var platforms = sumo_section.player_platforms.get(player_number, [])
		if platforms.is_empty():
			#print("No platforms to burn")
			return
	
	# Execute action with validation
	if action is Callable:
		var result = action.call()
		if result is bool && !result:
			pass
			#printerr("Action failed validation")
	else:
		pass
		#printerr("Invalid action type")

func _show_buy_menu():
	selected_index = 1  # Reset selection
	_clear_menu()
	_create_menu()
	if player_number < VariableDock.buy_options.size() and not VariableDock.buy_options[player_number].is_empty():
		# Use buy options for the current player
		_populate_submenu(VariableDock.buy_options[player_number])
	else:
		#print("No platforms available for purchase for Player.", player_number)
		_clear_menu()  # Clear the menu if no options are available
	
	_update_highlight()


func _show_sell_menu():
	selected_index = 1  # Reset selection
	_clear_menu()
	_create_menu()

	# Ensure player has platforms to sell
	if player_number < VariableDock.sell_options.size() and player_number in sumo_section.player_platforms:
		var owned_platforms = sumo_section.player_platforms[player_number]
		var sell_percentages = [100, 75, 50, 25]

		var options = []
		for percentage in sell_percentages:
			var num_to_sell = ceil(owned_platforms.size() * percentage / 100.0)
			var platforms_to_sell = owned_platforms.slice(0, num_to_sell)

			options.append({
				"text": "%d%%" % [percentage],
				"action": Callable(self, "_execute_sell_action").bind(platforms_to_sell, player_number),
			})

		_populate_submenu(options)
	else:
		pass
		#print("No platforms available to sell for Player", player_number)

	_update_highlight()

func _execute_sell_action(platforms: Array, player_number: int):
	sumo_section._sell_item_action(platforms, player_number)
	_clear_menu()
	
func _execute_buy_action(platforms: Array, player_number: int):
	sumo_section._buy_item_action(platforms, player_number)
	_clear_menu()
	
func _populate_submenu(options):
	if options == null:
		#print("Error: 'options' is null.")
		return
	var triangle_width = 80  # Width of each triangle
	for i in range(options.size()):
		var position = Vector2(i * triangle_width * 0.5, 0)  # X-offset for spacing
		var flip = i % 2 == 1  # Alternate triangle flip
		buttons.append(_create_triangle_button(options[i]["text"], position, flip, options[i]["action"]))

func _update_energy_sync():
	#mmain problem is that what if a player makes a purchase idk if it would override the purchase and make energy
	#stay the same. I guess i have to do like this. with recent_purchase being a global variable probably and updating
	#for player upon a purchase being made
	#print(current_energy, " current_energy")
	VariableDock.buyer_current_energy[player_number] = current_energy
	VariableDock.seller_current_energy[player_number] = current_energy
	#print(VariableDock.seller_current_energy[player_number], " VariableDock.seller_current_energy[player_number]", VariableDock.buyer_current_energy[player_number], " VariableDock.buyer_current_energy[player_number]")
