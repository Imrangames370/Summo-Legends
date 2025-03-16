extends Node3D
var spawn_points := []
const ASTEROID_SCENE = preload("res://Scenes/asteroid_full_physics.tscn")
var asteroid_radius 
var asteroid_shower_trigger_mark = 1
var length_of_asteroid_shower_seconds = 7
var asteroid_seconds_frequency = 2
var asteroid_shower_start_check_seconds_frequency = 21 

# Add these constants at the top of your script for energy orb pulsing
const PULSE_SPEED := 5.0
const MIN_EMISSION := 1.5
const MAX_EMISSION := 4.0
const PULSE_RANGE := MAX_EMISSION - MIN_EMISSION

@onready var sumo_section: Node3D = $"." #needs to be here to call via player script platform purchase

# Dictionary to track energy orbs associated with platforms
var platform_energy_orbs = {}

#RESET ALL OWNERSHIP AND COLORS UPON CALLING SPHERE_UPDATE PLEASE

# Tracks platforms scheduled for destruction. ESSENTIAL FOR PLAYER CONTROLLED PLATFORM DELETION.
var scheduled_for_destruction = {}

# Variables for platform deletion
var disappearing_platform_seconds = 3 #dont change as fire is set to 2.9 lifetime via gpu particles 3d in its scene
var random_chance_odds = 0

var asteroid_spawn_timer = null
var asteroid_shower_timer = null
var asteroid_shower_stop_timer = null

var deletion_timer = null

# Organized platforms by ring
var platform_rings = []
"""AUCTION VARIABLE START"""
var marketplace = []  # Global list of platforms for sale. Each entry is a dictionary with {platform, price, seller_id}.
"""AUCTION VARIABLE END"""
"""PLAYER PLATFORM OWNERSHIP START"""
var player_platforms = {
	0: [],
	1: [],
	2: [],
	3: [],
	4: [],
	5: [],
	6: [],
	7: [],
	8: [],
	9: [],
}
"""PLAYER PLATFORM OWNERSHIP END"""

"""ROTATION VARIABLES"""
var current_rotation_y = 0.0
var target_rotation_y = 0.0
var current_rotation_x = 0.0
var target_rotation_x = 0.0
var current_rotation_z = 0.0
var target_rotation_z = 0.0
var rotation_speed = 4.0  # Degrees per second
var static_bodies = []  # Array to store references to all StaticBody3D nodes
var changed_platforms = []  # Keep track of platforms whose colors were changed
"""ROTATION VARIABLES END"""
var material
var new_radius = 25
var rings_parent: Node3D

var platform_rotation_targets = {}
var platform_height_targets = {}
var player_rotation_speed = 20 #Degrees per second. this feels like a good speed, feels responsive and natural. the right speed for a fast paced game
var trigger_update_stage_on_rematch_variable

func rematch_stage_reset():
	if VariableDock.match_end == 1 and VariableDock.reset_primary_custom_stage_tracker == 0:
		VariableDock.reset_primary_custom_stage_tracker = 1 #ensures this does not repeat. This must be done first.
		# Reset all VariableDock variables
		VariableDock.rematch_reset_variable_dock()

		# Reset all stage variables
		reset_stage_variables()
func reset_stage_variables():
	# Reset ownership
	rematch_reset_delete_all_platform_ownership()
	
	# Reset arrays
	platform_rings.clear()
	marketplace.clear()
	changed_platforms.clear()
	static_bodies.clear()
	platform_height_targets.clear()
	platform_rotation_targets.clear()

	# Reset dictionaries
	platform_energy_orbs.clear()
	scheduled_for_destruction.clear()

	#print("Stage variables reset to default values.")
	# Reset rotation variables to initial state
	current_rotation_y = 0.0
	target_rotation_y = 0.0
	current_rotation_x = 0.0
	target_rotation_x = 0.0
	current_rotation_z = 0.0
	target_rotation_z = 0.0
	
	random_chance_odds = VariableDock.slider_random_chance_odds
	disappearing_platform_seconds = VariableDock.slider_disappearing_platform_seconds
	trigger_update_stage_on_rematch_variable = 2 #queue update stage to happen when rematch actually happens so burn and enery orbs dont happen till new game starts

func trigger_update_stage_on_rematch():
	if VariableDock.game_in_play == 2 and trigger_update_stage_on_rematch_variable == 2:
		trigger_update_stage_on_rematch_variable = 1
		_update_stage()
		#not the full reset function for stage this just makes sure update stage only gets called when the new game starts.
		#queue update stage to happen when rematch actually happens so burn and enery orbs dont happen till new game starts
func rematch_reset_delete_all_platform_ownership():
	for platform in changed_platforms:
		if not platform:
			continue
		change_material(platform, 0)
	
	for player_number in range(0, 10):
		if player_platforms.has(player_number):
			player_platforms[player_number].clear()
			#print("Cleared platforms for player:", player_number)
		else:
			pass
			#print("No platforms found for player:", player_number)
	
	changed_platforms.clear()
	
	for platform in platform_energy_orbs.keys():
		var orb = platform_energy_orbs[platform]
		if orb:
			orb.queue_free()
		platform_energy_orbs.erase(platform)
	#print("All energy orbs have been deleted.")
	
	update_ui()
	_update_stage()
	#print("All platform ownership and materials have been reset.")
	
	### BREAK DEATH REMATCH CODE END

func change_material(platform: StaticBody3D, player_number) -> void:
	if VariableDock.sphere_mesh_array[player_number].material == VariableDock.TRANSPARENT_MATERIAL:
		#make sure player is not currently invisible as i do not want to be changing platform ownership or 
		#coloring platforms while a player is invisible.
		return
	if not platform:
		#print("Platform is null!")
		return

	# Remove from unowned group first
	if platform.is_in_group("unowned_platforms"):
		platform.remove_from_group("unowned_platforms")

	# Update ownership tracking
	update_platform_ownership_for_material_change(platform, player_number)

	for child in platform.get_children():
		if child is MeshInstance3D:
			if player_number >= 0 and player_number <= 10:
				# Apply player's material
				if VariableDock.sphere_mesh_array.size() > player_number:
						var player_material = VariableDock.sphere_mesh_array[player_number].material
						child.material_override = player_material
				else:
					pass
					#print("Invalid player number or material not found for player: ", player_number)
			else:
				# Set default material
				var material = child.material_override
				if not material:
					material = StandardMaterial3D.new()
					child.material_override = material
				# Configure default material properties
				material.albedo_color = Color8(204, 160, 2)  # Original gold
				material.metallic = 0.1
				material.roughness = 0.7
				material.emission_enabled = false
				material.rim_enabled = true
				material.rim = 0.3
				material.rim_tint = 0.8

			# Track changed platforms
			if platform not in changed_platforms:
				changed_platforms.append(platform)
				#print("Added platform to changed_platforms:", platform.name)

	# Update groups for ownership
	if player_number >= 0:
		platform.add_to_group("player_%d_platforms" % player_number)
	else:
		platform.add_to_group("neutral_platforms")




func log_platform_positions(platforms):
	for platform in platforms:
		if platform is StaticBody3D:
			pass
			#print("Platform position: ", platform.global_transform.origin)
# Reset all changed platform colors to default

func update_platform_ownership_for_material_change(platform: StaticBody3D, player_number: int):
	# Remove from all players
	for p in player_platforms:
		if platform in player_platforms[p]:
			player_platforms[p].erase(platform)
	
	# Add to new owner
	if not player_platforms.has(player_number):
		player_platforms[player_number] = []
	if not platform in player_platforms[player_number]:
		player_platforms[player_number].append(platform)
		#print("Player", player_number, "now owns platform at", platform.global_transform.origin)

func reset_platform_materials():
	for platform in changed_platforms:
		if not platform:
			continue
		change_material(platform, 0)  # Reset to default material
	changed_platforms.clear()  # Clear the tracking array
	#print("All platform materials reset to default.")
	player_platforms[0].clear()
	player_platforms[1].clear()
	player_platforms[2].clear()
	player_platforms[3].clear()
	player_platforms[4].clear()
	player_platforms[5].clear()
	player_platforms[6].clear()
	player_platforms[7].clear()
	player_platforms[8].clear()
	player_platforms[9].clear()
	update_ui()
	#print("All platform ownership reset to default.")

func update_ui():
	VariableDock.player_10_platforms_display = player_platforms[0].size() #player 10 is player number 0
	VariableDock.player_1_platforms_display = player_platforms[1].size()
	VariableDock.player_2_platforms_display = player_platforms[2].size()
	VariableDock.player_3_platforms_display = player_platforms[3].size()
	VariableDock.player_4_platforms_display = player_platforms[4].size()
	VariableDock.player_5_platforms_display = player_platforms[5].size()
	VariableDock.player_6_platforms_display = player_platforms[6].size()
	VariableDock.player_7_platforms_display = player_platforms[7].size()
	VariableDock.player_8_platforms_display = player_platforms[8].size()
	VariableDock.player_9_platforms_display = player_platforms[9].size()
	
	#print(VariableDock.player_2_platforms_display, "player_2_platforms_display")
	#print(VariableDock.player_1_platforms_display, "player_1_platforms_display")

func _ready():
	_clear_children()
	player_platforms[0].clear()
	player_platforms[1].clear()
	player_platforms[2].clear()
	player_platforms[3].clear()
	player_platforms[4].clear()
	player_platforms[5].clear()
	player_platforms[6].clear()
	player_platforms[7].clear()
	player_platforms[8].clear()
	player_platforms[9].clear()
	update_ui()
	create_stage(new_radius, VariableDock.segments_number)
	_prepare_platform_rings()
	_start_platform_deletion()
	reset_platform_materials()
	deletion_timer.connect("timeout", Callable(self, "_delete_outermost_platform")) #connects deletion timer once. Ensures it is only connected once by calling it in _ready. only needs to be connected once
	log_platform_positions(static_bodies)
	
func pulsing_effect():
	var time = Time.get_ticks_msec() / 1000.0
	var pulse_speed = 3.0  # Faster pulse speed
	var base_emission = 1.5
	var pulse_strength = 1.0  # Stronger pulse variation

	for platform in platform_energy_orbs:
		var orb = platform_energy_orbs[platform]
		if orb and is_instance_valid(orb):
			var mesh = orb.get_child(0)
			if mesh is MeshInstance3D:
				var material = mesh.material_override
				if material:
					var phase = material.get_meta("phase", 0.0)
					# Changed base color to a calming blue
					var base_color = material.get_meta("base_emission", Color(0.15, 0.4, 1.0))
					
					# Calculate pulse value
					var pulse = sin(time * pulse_speed + phase) * pulse_strength + base_emission
					
					# Update emission properties
					material.emission_energy_multiplier = pulse
					
					# Calculate color variation (soft blue to bright cyan)
					var color_factor = 0.5 + (pulse - base_emission) * 0.5
					material.emission = Color(
						base_color.r * 0.7,  # Maintain subtle red component
						base_color.g * (0.6 + 0.4 * color_factor),  # Gentle green variation
						base_color.b * (0.8 + 0.2 * color_factor)   # Brightness variation in blue
					)
func _process(delta):
	asteroid_spawn()
	if VariableDock.mark_player_connected_count != 0: # make it so if no players are added it doesnt run process yet
		trigger_update_stage_on_rematch() #very important. KEEP. otherwise rematch will not work and nor will auto burn deathmatch
		pulsing_effect()
		rematch_stage_reset() #crucial for resetting on main menu or rematch. MUST KEEP
		# Check if static_bodies is not empty
		if static_bodies.size() > 0 and randf() < VariableDock.energy_orb_spawn_rate:
			var random_platform = static_bodies[randi() % static_bodies.size()]
			var position = random_platform.global_transform.origin
			create_energy_orb(position + Vector3(0, 4, 0), random_platform)
		if static_bodies.size() > 0 and randf() < VariableDock.modifier_spawn_rate:
			var random_platform = static_bodies[randi() % static_bodies.size()]
			create_random_math_modifier(random_platform)
		# Gradually adjust platform rotations
		for platform in platform_rotation_targets.keys():
			if not platform:
				continue

			var current_rotation = platform.rotation_degrees
			var target_rotation = platform_rotation_targets[platform]

			# Check if rotation is complete
			if current_rotation.distance_to(target_rotation) < 0.01:
				platform_rotation_targets.erase(platform)
				continue

			# Incremental rotation adjustment (component-wise lerp)
			var step = player_rotation_speed * delta
			var new_rotation = Vector3(
				lerp(current_rotation.x, target_rotation.x, step / current_rotation.distance_to(target_rotation)),
				lerp(current_rotation.y, target_rotation.y, step / current_rotation.distance_to(target_rotation)),
				lerp(current_rotation.z, target_rotation.z, step / current_rotation.distance_to(target_rotation))
			)

			platform.rotation_degrees = new_rotation

			# Synchronize orb rotation
			if platform in platform_energy_orbs:
				var orb = platform_energy_orbs[platform]
				if orb:
					orb.rotation_degrees = new_rotation



		# Speed of height adjustment
		var height_adjustment_speed = 5.0

		# Gradually adjust the platform heights
		for platform in platform_height_targets.keys():
			if not platform:
				continue

			var current_height = platform.global_transform.origin.y
			var target_height = platform_height_targets[platform]

			if abs(current_height - target_height) < 0.01:
				# Snap to target height when close enough
				var final_transform = platform.global_transform
				final_transform.origin.y = target_height
				platform.global_transform = final_transform
				platform_height_targets.erase(platform)  # Remove from targets
				continue

			# Smoothly adjust height using interpolation
			var new_height = lerp(current_height, target_height, height_adjustment_speed * delta)
			var platform_transform = platform.global_transform
			platform_transform.origin.y = new_height
			platform.global_transform = platform_transform

			# Adjust the associated orb's height
			if platform in platform_energy_orbs:
				var orb = platform_energy_orbs[platform]
				if orb:
					var orb_transform = orb.global_transform
					orb_transform.origin.y = new_height + 2  # Maintain offset
					orb.global_transform = orb_transform
		if VariableDock.PlayerPlatformControl == 1:
			if VariableDock.player_1_platforms_display != player_platforms[1].size():
				#print("player_1_platforms_display pre update", VariableDock.player_1_platforms_display)
				#print("player_1_platforms_display size pre update", player_platforms[1].size())
				VariableDock.player_1_platforms_display = player_platforms[1].size()
				#print("player_1_platforms_display post update", VariableDock.player_1_platforms_display)
				#print("player_1_platforms_display size post update", player_platforms[1].size())
			if VariableDock.player_2_platforms_display != player_platforms[2].size():
				VariableDock.player_2_platforms_display = player_platforms[2].size()
		# Handle rotation logic
		if VariableDock.Rotating == 1:
			# Y rotation
			if VariableDock.Degrees_Type == 1:
				target_rotation_y = VariableDock.random_degrees_y
				current_rotation_y = _update_rotation(delta, target_rotation_y, current_rotation_y, "y")
			elif VariableDock.Degrees_Type == 2:
				target_rotation_x = VariableDock.random_degrees_x
				current_rotation_x = _update_rotation(delta, target_rotation_x, current_rotation_x, "x")
			elif VariableDock.Degrees_Type == 3:
				target_rotation_z = VariableDock.random_degrees_z
				current_rotation_z = _update_rotation(delta, target_rotation_z, current_rotation_z, "z")
		# Handle stage updates
		if new_radius != VariableDock.circle_radius:
			new_radius = VariableDock.circle_radius
			_update_stage()
			_update_stage()
		if random_chance_odds != VariableDock.slider_random_chance_odds:
			random_chance_odds = VariableDock.slider_random_chance_odds
		if disappearing_platform_seconds != VariableDock.slider_disappearing_platform_seconds:
			disappearing_platform_seconds = VariableDock.slider_disappearing_platform_seconds
			_start_platform_deletion()
			#print("disappearing_platform_seconds, ",disappearing_platform_seconds)
		
func _update_rotation(delta, target_rotation, current_rotation, axis):
	target_rotation = wrapf(target_rotation, -180, 180)
	current_rotation = wrapf(current_rotation, -180, 180)
	var delta_rotation = target_rotation - current_rotation
	delta_rotation = wrapf(delta_rotation, -180, 180)

	if abs(delta_rotation) > 0.01:
		var rotation_step = player_rotation_speed * delta
		if delta_rotation > 0:
			current_rotation = min(current_rotation + rotation_step, current_rotation + delta_rotation)
		elif delta_rotation < 0:
			current_rotation = max(current_rotation - rotation_step, current_rotation + delta_rotation)

		for static_body in static_bodies:
			match axis:
				"x":
					static_body.rotation_degrees.x = current_rotation
				"y":
					static_body.rotation_degrees.y = current_rotation
				"z":
					static_body.rotation_degrees.z = current_rotation

	return current_rotation

func _update_stage():
	deletion_timer.stop()
	_clear_children()
	create_stage(new_radius, VariableDock.segments_number)
	_prepare_platform_rings()
	reset_platform_materials()
	deletion_timer.start()
	asteroid_shower_trigger_mark = 1
	asteroid_spawn_timer = null
	asteroid_shower_timer = null
	asteroid_shower_stop_timer = null
	#print("Updated platform rings:", platform_rings)

func _clear_children():
	#print("Clearing children. Keeping timer intact.")
	for child in get_children():
		if child != deletion_timer:
			#print("Freeing child:", child.name)
			remove_child(child)
			child.queue_free()
			
	static_bodies.clear()
	
func create_stage(radius, segments):
	if radius <= 10:
		# Always create the center platform as backup if radius too small
		create_center_platform()
		return  # Do not generate rings if radius is too small
	create_square_segments(radius, segments)
	log_platform_positions(static_bodies)

func create_center_platform():
	var static_body = StaticBody3D.new()
	add_child(static_body)
	static_bodies.append(static_body)  # Track the static body
	static_body.add_to_group("center_platform")  # Add to group to prevent deletion
	static_body.add_to_group("ground")  # Group for general ground platforms

	static_body.collision_layer = 1
	static_body.collision_mask = 1

	# Create a flat square mesh for the center platform
	var mesh_instance = MeshInstance3D.new()
	var box_mesh = BoxMesh.new()
	box_mesh.size = Vector3(20, 2, 20)  # Adjust size as needed
	mesh_instance.mesh = box_mesh

	# Material for visualization
	material = StandardMaterial3D.new()
	material.albedo_color = Color8(204, 160, 2)  # Orange
	mesh_instance.material_override = material
	static_body.add_child(mesh_instance)

	# Add collision shape
	var collision_shape = CollisionShape3D.new()
	var box_shape = BoxShape3D.new()
	box_shape.extents = Vector3(10, 1, 10)  # Adjust to match box mesh
	collision_shape.shape = box_shape
	static_body.add_child(collision_shape)
	static_body.transform.origin = Vector3(0, -10, 0)


func create_square_segments(radius: float, segments: int):
	if segments <= 0:
		#print("Segments must be greater than zero!")
		return
		# Create materials array
	#var materials = [
		#load("res://Assets/player_solid_color_skins/orange_material.tres"), #desert plain flatter placeholder
		#load("res://Assets/player_solid_color_skins/yellow_material.tres"), #cracked desert placeholder
		#load("res://Assets/player_solid_color_skins/green_material.tres"), #desert plain hilly placeholder
		#load("res://Assets/player_solid_color_skins/red_material.tres"), #placeholder for lava
		#load("res://Assets/player_solid_color_skins/cyan_material.tres") #placeholder for water
	#]
	# Calculate the size of each square
	var square_size = radius / segments

	# Start position for the grid, centering it around (0, 0)
	var start_pos_x = -radius / 2 + square_size / 2
	var start_pos_z = -radius / 2 + square_size / 2

	for x in range(segments):
		for z in range(segments):
			var static_body = StaticBody3D.new()
			add_child(static_body)
			# Add neutral platform to unowned group
			static_body.add_to_group("unowned_platforms")
			static_bodies.append(static_body)
			static_body.add_to_group("ground")
			
			static_body.collision_layer = 1
			static_body.collision_mask = 1

			# Create a flat square mesh
			var mesh_instance = MeshInstance3D.new()
			var box_mesh = BoxMesh.new()
			box_mesh.size = Vector3(square_size, 1, square_size)
			mesh_instance.mesh = box_mesh

			#apply random material
			#var random_material = materials[randi() % materials.size()]
			#mesh_instance.material_override = random_material
			static_body.add_child(mesh_instance)

			# Add collision shape
			var collision_shape = CollisionShape3D.new()
			var box_shape = BoxShape3D.new()
			box_shape.extents = Vector3(square_size / 2, 0.5, square_size / 2)
			collision_shape.shape = box_shape
			static_body.add_child(collision_shape)

			# Calculate position
			static_body.transform.origin = Vector3(
				start_pos_x + x * square_size,
				0,
				start_pos_z + z * square_size
			)

			#print("Added square at:", static_body.transform.origin)
			#print("Added to static_bodies:", static_body.name)
func _prepare_platform_rings():
	platform_rings.clear()
	for static_body in static_bodies:
		if not static_body.is_in_group("center_platform"):
			var distance = static_body.global_transform.origin.length()
			#print("Platform:", static_body.name, "Distance:", distance)
			var added = false
			for ring in platform_rings:
				if abs(ring[0] - distance) < 0.5:  # Adjust tolerance
					ring[1].append(static_body)
					added = true
					break
			if not added:
				platform_rings.append([distance, [static_body]])
	platform_rings.sort_custom(Callable(self, "_compare_rings_by_distance"))  # Fixed usage
	#print("Prepared rings:", platform_rings)
	
func create_energy_orb(position: Vector3, platform: StaticBody3D):
	var energy_orb = StaticBody3D.new()
	add_child(energy_orb)
	energy_orb.global_transform.origin = position
	energy_orb.add_to_group("energy_orbs")
	energy_orb.collision_layer = 2
	energy_orb.collision_mask = 2

	var mesh_instance = MeshInstance3D.new()
	var sphere_mesh = SphereMesh.new()
	sphere_mesh.radius = 1.0
	mesh_instance.mesh = sphere_mesh

	var material = StandardMaterial3D.new()
	material.albedo_color = Color(0.1, 0.3, 0.8)
	material.emission_enabled = true
	material.emission = Color(0.15, 0.4, 1.0)
	material.emission_energy_multiplier = 2.0
	# Add random phase for pulsing effect
	var phase = randf() * 2 * PI
	material.set_meta("phase", phase)
	material.set_meta("base_emission", Color(0.15, 0.4, 1.0))  # Store base color
	mesh_instance.material_override = material

	energy_orb.add_child(mesh_instance)

	var collision_shape = CollisionShape3D.new()
	var shape = SphereShape3D.new()
	shape.radius = 1.1
	collision_shape.shape = shape
	energy_orb.add_child(collision_shape)

	platform_energy_orbs[platform] = energy_orb
	# Add auto-delete timer
	var delete_timer = Timer.new()
	delete_timer.wait_time = 7.0 # 7 seconds is how long energy orbs last
	delete_timer.one_shot = true
	delete_timer.connect("timeout", Callable(self, "_on_orb_timeout").bind(energy_orb, platform))
	energy_orb.add_child(delete_timer)
	delete_timer.start()

func _on_orb_timeout(orb: StaticBody3D, platform: StaticBody3D):
	if is_instance_valid(orb):
		orb.queue_free()
	if platform in platform_energy_orbs and platform_energy_orbs[platform] == orb:
		platform_energy_orbs.erase(platform)
	
func _compare_rings_by_distance(a, b) -> bool:
	return a[0] < b[0]  # Return true if 'a' should precede 'b'

func _start_platform_deletion():
	if !deletion_timer:
		deletion_timer = Timer.new()
		add_child(deletion_timer)
	deletion_timer.wait_time = disappearing_platform_seconds
	deletion_timer.one_shot = false  # Timer repeats
	deletion_timer.start()
	#print("Platform deletion timer started with wait_time:", disappearing_platform_seconds)


func _delete_outermost_platform():
	#print("Timer triggered deletion check")
	
	# Generate a random chance and compare against odds
	var chance = randi() % 100  # Random number between 0 and 99
	if chance >= random_chance_odds:
		#print("No platform deleted this time (random chance).")
		return
		
	# Check if there are any rings to delete
	if platform_rings.is_empty():
		#print("No rings left to delete, stopping timer.")
		deletion_timer.stop()
		return

	# Reference the outermost ring
	var outer_ring = platform_rings.back()[1]

	# Check if the outer ring has platforms to remove
	if not outer_ring.is_empty():
		var platform_to_remove = outer_ring.pop_back()
		##print("Deleting platform:", platform_to_remove.name)

		# Delete orbs on the platform
		if is_instance_valid(platform_to_remove): #essential for ensuring if a outer platform gets deleted via manual player
			#delete it does not crash game. This if statement skips over already deleted platforms via manual delete.
			_create_warning_effect(platform_to_remove)
		else:
			pass
			#print("The platform to remove is already freed.")

		# Stop the timer if no platforms remain
		if platform_rings.is_empty():
			deletion_timer.stop()
	else:
		#print("Removing entire outermost ring.")
		platform_rings.pop_back()

func _create_warning_effect(platform: StaticBody3D):
	# Create warning particles at correct global position
	var particles = _create_warning_particles(platform.global_transform.origin + Vector3(0, 0.5, 0))
	add_child(particles)  # Add to stage instead of platform
	
	# Schedule platform deletion
	var timer = get_tree().create_timer(disappearing_platform_seconds)
	timer.connect("timeout", Callable(sumo_section, "_delete_platform_with_particles").bind(platform, particles))
func _delete_orbs_on_platform(platform: StaticBody3D):
	if platform in platform_energy_orbs:
		var orb = platform_energy_orbs[platform]
		if orb:
			orb.queue_free()  # Remove the orb from the scene
		platform_energy_orbs.erase(platform)  # Remove the association


func _delete_platform_with_particles(platform: StaticBody3D, particles: GPUParticles3D):
	#by using max_particle_lifetime to prolong manual queue delete, cuz they need to be queue deleted but would prefer them to shrink on their own to not be visible
	#queue delete is just to remove the physical node for keeping it lag free.
	#using this with a low lifetime of like 2 seconds combined with a low randomness of like .5 
	#and the max_particle_lifetime value being high lets them go away on their own instead of getting jarringly insta deleted mid animation
	if is_instance_valid(platform):
		_delete_orbs_on_platform(platform)
		_delete_platform(platform)
	if is_instance_valid(particles):
		particles.queue_free()

func _create_warning_particles(global_position: Vector3) -> GPUParticles3D:
	var particles = GPUParticles3D.new()
	
	# Position particles 0.5 units above platform surface
	particles.global_transform.origin = global_position
	
	# PARTICLE MATERIAL SETUP
	var material = ParticleProcessMaterial.new()
	material.lifetime_randomness = 0.3
	material.gravity = Vector3(0, 0.2, 0)  # Slight upward lift
	
	# Flame-shaped emission
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	material.emission_box_extents = Vector3(1.5, 0.1, 1.5)  # Wide, flat emission
	
	# Particle movement parameters
	material.direction = Vector3(0, 1, 0)  # Mostly upward
	material.spread = 45  # Wide cone of fire
	
	# Flame color ramp
	var gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 0))     # Bright yellow core
	gradient.add_point(0.3, Color(1, 0.5, 0))   # Orange
	gradient.add_point(0.7, Color(0.8, 0, 0))   # Dark red
	gradient.add_point(1.0, Color(0, 0, 0, 0))  # Fade out
	var color_ramp = GradientTexture1D.new()
	color_ramp.gradient = gradient
	material.color_ramp = color_ramp
	
	# Flame scale and flicker
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 0.0))
	scale_curve.add_point(Vector2(0.1, 0.8), 0, 0, Curve.TANGENT_LINEAR)
	scale_curve.add_point(Vector2(0.3, 1.2))
	scale_curve.add_point(Vector2(0.7, 0.9))
	scale_curve.add_point(Vector2(1.0, 0.0))
	var scale_texture = CurveTexture.new()
	scale_texture.curve = scale_curve
	material.scale_curve = scale_texture
	
	# Random rotation and flicker
	material.angular_velocity_curve = _create_flicker_curve()
	
	# Final setup
	particles.process_material = material
	particles.draw_pass_1 = _create_flame_mesh()
	particles.amount = 16
	particles.lifetime = disappearing_platform_seconds * 0.9  # Slightly shorter than deletion time
	particles.one_shot = true
	particles.emitting = true
	
	return particles

func _create_flame_mesh() -> ArrayMesh:
	var mesh = ArrayMesh.new()
	var st = SurfaceTool.new()
	st.begin(Mesh.PRIMITIVE_TRIANGLES)
	
	var width = 0.8
	var height = 1.2
	var half_w = width / 2.0
	var half_h = height / 2.0
	
	# First quad (X-Y plane)
	# Vertex 0
	st.set_uv(Vector2(0, 1))
	st.add_vertex(Vector3(-half_w, -half_h, 0))
	# Vertex 1
	st.set_uv(Vector2(1, 1))
	st.add_vertex(Vector3(half_w, -half_h, 0))
	# Vertex 2
	st.set_uv(Vector2(1, 0))
	st.add_vertex(Vector3(half_w, half_h, 0))
	# Vertex 3
	st.set_uv(Vector2(0, 0))
	st.add_vertex(Vector3(-half_w, half_h, 0))
	
	# Indices for first quad
	st.add_index(0)
	st.add_index(1)
	st.add_index(2)
	st.add_index(0)
	st.add_index(2)
	st.add_index(3)
	
	# Second quad (Y-Z plane)
	# Vertex 4
	st.set_uv(Vector2(0, 1))
	st.add_vertex(Vector3(0, -half_h, -half_w))
	# Vertex 5
	st.set_uv(Vector2(1, 1))
	st.add_vertex(Vector3(0, -half_h, half_w))
	# Vertex 6
	st.set_uv(Vector2(1, 0))
	st.add_vertex(Vector3(0, half_h, half_w))
	# Vertex 7
	st.set_uv(Vector2(0, 0))
	st.add_vertex(Vector3(0, half_h, -half_w))
	
	# Indices for second quad
	st.add_index(4)
	st.add_index(5)
	st.add_index(6)
	st.add_index(4)
	st.add_index(6)
	st.add_index(7)
	
	st.generate_normals()
	st.generate_tangents()
	st.commit(mesh)
	
	# Material setup (same as before)
	var material = StandardMaterial3D.new()
	material.vertex_color_use_as_albedo = true
	material.shading_mode = StandardMaterial3D.SHADING_MODE_UNSHADED
	material.transparency = StandardMaterial3D.TRANSPARENCY_ALPHA
	material.cull_mode = StandardMaterial3D.CULL_DISABLED
	material.albedo_texture = _create_flame_noise_texture()
	
	mesh.surface_set_material(0, material)
	return mesh

func _create_flicker_curve() -> CurveTexture:
	var curve = Curve.new()
	# Create random flicker pattern
	for i in 5:
		var pos = i / 4.0
		curve.add_point(Vector2(pos, randf_range(-10, 10)))
	var texture = CurveTexture.new()
	texture.curve = curve
	return texture

func _create_flame_noise_texture() -> NoiseTexture2D:
	var noise = FastNoiseLite.new()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.fractal_octaves = 3
	var texture = NoiseTexture2D.new()
	texture.noise = noise
	return texture
	
func _delete_platform(platform: StaticBody3D):
#WORKS PERFECTLY WITHOUT ANY BUGS PLEASE DO NOT CHANGE.
#AVOID HAVING #printS AS 30 x like 6 #prints all at once say u change 30 platforms all at once can cause serious lag.
	if platform:
		# IMPORTANT Remove platform from sell list
		for i in range(marketplace.size()):
			if marketplace[i]["platform"] == platform:
				marketplace.remove_at(i)
				break
		# Remove any associated energy orb
		if platform in platform_energy_orbs:
			var orb = platform_energy_orbs[platform]
			if orb:
				orb.call_deferred("queue_free")  
			platform_energy_orbs.erase(platform)

		# Remove platform from ownership
		for platforms in player_platforms.values():
			if platform in platforms:
				platforms.erase(platform)
		
		# Update UI to reflect ownership change
		update_ui()

		# Remove from static_bodies and queue for deletion
		static_bodies.erase(platform)
		platform.call_deferred("queue_free")  # Ensure safe deletion
	else:
			pass
func trigger_platform_destruction_burn(platforms: Array, player_number: int):
	if player_number not in player_platforms:
		return
	var platforms_to_destroy = player_platforms[player_number]
	for platform in platforms_to_destroy:
		if scheduled_for_destruction.has(platform):
			continue  # Skip platforms already scheduled for destruction

		# Create warning particles at correct global position
		var particles = _create_warning_particles(platform.global_transform.origin + Vector3(0, .5, 0))
		add_child(particles)  # Add to stage instead of platform

		# Start destruction timer
		var timer = Timer.new()
		timer.one_shot = true
		timer.wait_time = disappearing_platform_seconds  # Initial timer duration
		timer.connect("timeout", Callable(self, "_handle_player_destruction").bind(platform, particles))
		add_child(timer)
		timer.start()

		# Mark platform as scheduled for destruction
		scheduled_for_destruction[platform] = timer

func _handle_player_destruction(platform: StaticBody3D, particles: GPUParticles3D):
	_delete_platform_with_particles(platform, particles)
	scheduled_for_destruction.erase(platform)

func adjust_timer(player_number: int):
	if player_number not in player_platforms:
		return

	for platform in player_platforms[player_number]:
		if scheduled_for_destruction.has(platform):
			var timer = scheduled_for_destruction[platform]
			if timer.time_left > 8.0:  # Adjust only if within 2 seconds of trigger
				timer.wait_time = max(timer.time_left - 5.0, 3.0)  # Min 3 seconds left
				#print("Timer adjusted for platform {platform.name}")
				return  # Adjust only once

			
func _on_destruction_timeout(platform: StaticBody3D, player_number: int):
#WORKS PERFECTLY WITHOUT ANY BUGS PLEASE DO NOT CHANGE.

		if player_number not in player_platforms:
			#print("Player does not own any platforms.")
			return
		# IMPORTANT Remove platform from sell list
		for i in range(marketplace.size()):
			if marketplace[i]["platform"] == platform:
				marketplace.remove_at(i)
				#print("Removed platform from sell list:", platform.name)
				break
		# Update player ownership
		if player_number in player_platforms:
			player_platforms[player_number].erase(platform)
		#print("Platform destroyed for player {player_number}")
		
		# Remove any associated energy orb
		if platform in platform_energy_orbs:
			var orb = platform_energy_orbs[platform]
			if orb:
				orb.call_deferred("queue_free")  
				#print("Deleted associated energy orb for platform:", platform.name)
			platform_energy_orbs.erase(platform)
		# Remove platform from ownership
		for platforms in player_platforms.values():
			if platform in platforms:
				platforms.erase(platform)
				#print("Removed platform from ownership:", platform.name)
		# Update UI to reflect ownership change
		update_ui()
		scheduled_for_destruction.erase(platform)
		platform.call_deferred("queue_free")  # Ensure safe deletion

func _adjust_platform_height(platforms: Array, direction: int):
	if platforms.is_empty():
		return
	for platform in platforms:
		if not platform:  # Safety check to avoid errors with deleted platforms
			continue
		const MIN_HEIGHT = -6
		const MAX_HEIGHT = 6

		if platform:
			var current_height = platform.global_transform.origin.y
			var target_height = clamp(current_height + direction, MIN_HEIGHT, MAX_HEIGHT)

			if current_height != target_height:
				platform_height_targets[platform] = target_height

func _rotate_platform(platforms: Array, rotation_axis: Vector3):
	for platform in platforms:
		if not platform:  # Safety check to avoid errors with deleted platforms
			continue
		var current_rotation = platform.rotation_degrees
		var target_rotation = current_rotation + rotation_axis * 30 # Adjust rotation amount

		# Store the target rotation for incremental adjustment
		platform_rotation_targets[platform] = target_rotation
		
		
func _sell_item_action(platforms: Array, seller_id: int):
	for platform in platforms:
		if platform in marketplace:
			#print("Platform already listed for sale.")
			continue
		var price = 10  # Fixed price per platform
		var sell_data = {"platform": platform, "price": price, "seller_id": seller_id}
		marketplace.append(sell_data)

		# Ensure sell options array for seller exists
		if seller_id >= VariableDock.sell_options.size():
			VariableDock.sell_options.resize(seller_id + 1)
		if not VariableDock.sell_options[seller_id]:
			VariableDock.sell_options[seller_id] = []
		VariableDock.sell_options[seller_id].append(sell_data)

		_populate_buy_options()
		update_ui()
func _buy_item_action(selected_listing_data: Dictionary, buyer_id: int):
	#print("_buy_item_action triggered")
	
	# Validate listing data
	if not selected_listing_data.has("price") or not selected_listing_data.has("seller_id") or not selected_listing_data.has("platforms"):
		#print("Error: Missing data in selected_listing_data:", selected_listing_data)
		return

	var price_per_platform = selected_listing_data["price"]
	var seller_id = selected_listing_data["seller_id"]
	var platforms = selected_listing_data["platforms"]

	# Calculate total cost
	var total_cost = platforms.size() * price_per_platform

	# Retrieve energy levels
	var buyer_energy = VariableDock.buyer_current_energy[buyer_id]
	var seller_energy = VariableDock.seller_current_energy[seller_id]
	
	#print(seller_energy, buyer_energy, "buyer_energy, seller_energy, at time of _buy_item_action")
	# Check if buyer has enough energy
	if buyer_energy < total_cost:
		#print("Player %d does not have enough energy to buy these platforms." % buyer_id)
		return

	# Perform transaction
	VariableDock.buyer_current_energy[buyer_id] -= total_cost
	VariableDock.seller_current_energy[seller_id] += total_cost

	# Transfer ownership of all platforms in the listing
	for platform in platforms:
		update_platform_ownership_auction_transaction(platform, buyer_id)

	# Remove the platforms from the marketplace
	for platform in platforms:
		for i in range(marketplace.size()):
			if marketplace[i]["platform"] == platform:
				marketplace.remove_at(i)  # Use remove_at to remove by index
				break

	# Reset the seller's sell list
	if seller_id < VariableDock.sell_options.size() and VariableDock.sell_options[seller_id]:
		VariableDock.sell_options[seller_id] = []
		
	sumo_section.update_ui()
	sumo_section._populate_buy_options()
	#print("Player %d bought %d platforms from Player %d for %d energy." % [buyer_id, platforms.size(), seller_id, total_cost])
	# IMPORTANT. trigger the _clear_menu function from the other script. this is the only way i have to do it right now even if it seems a bit bulky
	#it is difficult to trigger the _clear_menu function in the other script due to them being seperate scripts and it being player specific
	#and the button having to be made on this script.
	#print("buyer id: ", buyer_id)
	VariableDock.player_buy_transaction_clear_menu_trigger[buyer_id] = 1

# In stage.gd - Fix _populate_buy_options
func _populate_buy_options():
	# Clear existing buy options properly
	for buyer_id in VariableDock.buy_options.size():
		VariableDock.buy_options[buyer_id] = []
	
	# Group listings by seller
	var seller_listings = {}
	for listing in marketplace:
		var key = "%d-%d" % [listing["seller_id"], listing["price"]]
		if not seller_listings.has(key):
			seller_listings[key] = {
				"platforms": [],
				"price": listing["price"],
				"seller_id": listing["seller_id"]
			}
		seller_listings[key]["platforms"].append(listing["platform"])
	
	# Create buy options
	for listing in seller_listings.values():
		for buyer_id in range(10):
			if buyer_id != listing["seller_id"]:
				var action = Callable(sumo_section, "_buy_item_action").bind(
					{
						"platforms": listing["platforms"],
						"price": listing["price"],
						"seller_id": listing["seller_id"]
					},
					buyer_id
				)
				VariableDock.buy_options[buyer_id].append({
					"text": "%dP %dE" % [listing["platforms"].size(), listing["price"]],
					"action": action
				})
func update_platform_ownership_auction_transaction(platform: StaticBody3D, buyer_id: int):
	# Clear existing owners
	for p in player_platforms:
		if platform in player_platforms[p]:
			player_platforms[p].erase(platform)
	
	# Assign to new owner
	if not player_platforms.has(buyer_id):
		player_platforms[buyer_id] = []
	player_platforms[buyer_id].append(platform)
	#print("Ownership transferred to player", buyer_id)
	
	# Update groups
	platform.remove_from_group("unowned_platforms")
	platform.add_to_group("player_%d_platforms" % buyer_id)
	
	# Visual update
	change_material(platform, buyer_id)

# Add this function to create math modifiers




func create_random_math_modifier(platform: StaticBody3D):
	var modifier = StaticBody3D.new()
	modifier.add_to_group("math_modifiers")
	modifier.collision_layer = 2
	modifier.collision_mask = 2
	
	# Determine if modifier affects size or balls
	var is_size_modifier = randf() < 0.5
	var modifier_target = "size" if is_size_modifier else "balls"
	
	# Determine operation type and generate appropriate value
	var operation_rand = randf()
	var operation_type: String
	var modifier_value: int
	
	if operation_rand < 0.1:            # 10% Multiplication at operation_rand < 0.1
		operation_type = "multiply"
		if modifier_target == "size":
			modifier_value = size_multiplication_division_generate_weighted_random_value()
		elif modifier_target == "balls":
			modifier_value = balls_multiplication_division_generate_weighted_random_value()
	elif operation_rand < 0.2:         # 10% Division at operation_rand < 0.2
		operation_type = "divide"
		if modifier_target == "size":
			modifier_value = size_multiplication_division_generate_weighted_random_value()
		elif modifier_target == "balls":
			modifier_value = balls_multiplication_division_generate_weighted_random_value()
	elif operation_rand < 0.6:         # 40% Subtraction at operation_rand < 0.6
		operation_type = "subtract"
		if modifier_target == "size":
			modifier_value = size_generate_weighted_random_value()
		elif modifier_target == "balls":
			modifier_value = balls_generate_weighted_random_value()
	else:                              # 40% Addition
		operation_type = "add"
		if modifier_target == "size":
			modifier_value = size_generate_weighted_random_value()
		elif modifier_target == "balls":
			modifier_value = balls_generate_weighted_random_value()
	# Create 3D Label with appropriate symbol and styling
	var label = Label3D.new()
	var symbol = ""
	var color: Color
	var glow_color: Color
	
	# Set operation-specific styling with professional colors
	match operation_type:
		"add", "multiply":
			if operation_type == "add":
				symbol = "+"
			else:
				symbol = "×"
			color = Color("#4CAF50") if is_size_modifier else Color("#2196F3")
			glow_color = Color.BLACK #old color.lerp(Color.BLACK, 0.2)
		"subtract", "divide":
			if operation_type == "subtract":
				symbol = "-"
			else:
				symbol = "÷"
			color = Color("#F44336") if is_size_modifier else Color("#FF9800")
			glow_color = Color.BLACK
	# Configure label properties with solid outline (no glow)
	var target_text = "Size" if is_size_modifier else "Balls"
	label.text = "%s %s %d" % [target_text, symbol, modifier_value]
	
	# Load font and configure spacing
	var font_file = load("res://Assets/fonts/Orbitron-Bold.otf")
	var font_variation = FontVariation.new()
	font_variation.base_font = font_file
	font_variation.set_spacing(TextServer.SPACING_GLYPH, 2)  # Adjust 5 to desired spacing
	
	# Assign the configured font to the label
	label.font = font_variation
	
	label.pixel_size = 0.1
	label.modulate = color
	label.outline_size = 20  # Same outline size. SET to 0 TO DISABLE OUTLINE
	label.outline_modulate = glow_color  # Same color blend as before
	label.outline_modulate.a = 1.0  # Make outline fully opaque
	label.rotation_degrees = Vector3(-90, -90, 0)

	
	modifier.add_child(label)
	
	# Store metadata
	modifier.set_meta("modifier_operation", operation_type)
	modifier.set_meta("modifier_value", modifier_value)
	modifier.set_meta("modifier_target", modifier_target)
	
	# Collision shape
	var collision_shape = CollisionShape3D.new()
	collision_shape.shape = BoxShape3D.new()
	collision_shape.shape.extents = Vector3(2, 2, 2)
	modifier.add_child(collision_shape)
	
	# Position modifier above platform
	var pos = platform.global_transform.origin + Vector3(0, 4, 0)
	modifier.global_transform.origin = pos
	add_child(modifier)
	
	# Auto-delete timer
	var timer = Timer.new()
	timer.wait_time = 7
	timer.one_shot = true
	timer.connect("timeout", Callable(modifier, "queue_free"))
	modifier.add_child(timer)
	timer.start()

func size_multiplication_division_generate_weighted_random_value() -> int:
	# Weighted distribution for multiplication/division values
	var rand_val = randf()
	if rand_val < 0.7:   # 70% chance for small values (2-3)
		return randi_range(2, 3)
	elif rand_val < 0.90: # 20% chance for medium values (4-5)
		return randi_range(4, 5)
	elif rand_val < 0.95: # 5% chance for medium-high values (6-7)
		return randi_range(6, 7)
	elif rand_val < 0.98: # 3% chance for high values (8-10)
		return randi_range(8, 10)
	else:                # 2% chance for very high values (11-15)
		return randi_range(11, 15)
		
func size_generate_weighted_random_value() -> int:
	# Weighted random distribution (adjust probabilities as needed)
	var rand_val = randf()
	if rand_val < 0.7:  # 70% chance for small values (1-100)
		return randi_range(1, 100)
	elif rand_val < 0.90:  # 20% chance for medium values (101-500)
		return randi_range(101, 300)
	elif rand_val < 0.95:  # 5% chance for medium values (101-500)
		return randi_range(301, 500)
	elif rand_val < 0.98:  # 3% chance for medium values (101-500)
		return randi_range(501, 800)
	else:  # 2% chance for large values (501-999)
		return randi_range(801, 999) 

func balls_multiplication_division_generate_weighted_random_value() -> int:
	# Weighted distribution for multiplication/division values
	var rand_val = randf()
	if rand_val < 0.7:   # 70% chance for small values 
		return randi_range(2, 2)
	elif rand_val < 0.90: # 20% chance for medium values 
		return randi_range(3, 3)
	elif rand_val < 0.95: # 5% chance for medium-high values (6-7)
		return randi_range(4, 4)
	elif rand_val < 0.98: # 3% chance for high values (8-10)
		return randi_range(5, 5)
	else:                # 2% chance for very high values (11-15)
		return randi_range(6, 6)
		
func balls_generate_weighted_random_value() -> int:
	# Weighted random distribution (adjust probabilities as needed)
	var rand_val = randf()
	if rand_val < 0.7:  # 70% chance for small values (1-100)
		return randi_range(1, 2)
	elif rand_val < 0.90:  # 20% chance for medium values (101-500)
		return randi_range(3, 5)
	elif rand_val < 0.95:  # 5% chance for medium values (101-500)
		return randi_range(6, 9)
	elif rand_val < 0.98:  # 3% chance for medium values (101-500)
		return randi_range(10, 12)
	else:  # 2% chance for large values (501-999)
		return randi_range(13, 15) 
		
func apply_modifier_to_player(player_number: int, modifier: StaticBody3D):
	var operation_type = modifier.get_meta("modifier_operation")
	var modifier_value = modifier.get_meta("modifier_value")
	var modifier_target = modifier.get_meta("modifier_target")
	
	if modifier_target == "size":
		# Existing size handling code
		var current_radius = VariableDock.player_radius[player_number] #uhhh
		match operation_type:
			"add":
				# Use existing logarithmic scaling for addition
				var radius_increase = calculate_radius_change(modifier_value)
				current_radius += radius_increase
				#print("Player %d size increased by %f (modifier: +%d)" % [player_number, radius_increase, modifier_value])
			
			"subtract":
				# Use existing logarithmic scaling for subtraction
				var radius_decrease = calculate_radius_change(modifier_value)
				current_radius -= radius_decrease
				#print("Player %d size decreased by %f (modifier: -%d)" % [player_number, radius_decrease, modifier_value])
			
			"multiply":
				# Direct multiplication with modifier value
				current_radius *= modifier_value * .55
				#print("Player %d size multiplied by %d" % [player_number, modifier_value])
			
			"divide":
				# Direct division with modifier value (ensure no division by zero)
				if modifier_value != 0:
					current_radius /= modifier_value
					#print("Player %d size divided by %d" % [player_number, modifier_value])
				else:
					pass
					#print("Invalid division by zero attempted")
		# Apply minimum size constraint
		current_radius = max(current_radius, 0.05)
		# Update player state
		VariableDock.player_radius[player_number] = current_radius
		VariableDock.player_update_modifier[player_number] = 2
	else:
		# Handle ball count modification
		var current_balls = VariableDock.player_number_of_alive_balls[player_number]
		var new_balls = current_balls
		var delta = 0
		
		match operation_type:
			"add":
				new_balls += modifier_value
				delta = modifier_value
				#VariableDock.player_current_lives[player_number] += delta
			"subtract":
				new_balls = max(new_balls - modifier_value, 0)
				delta = min(modifier_value, current_balls)
				#VariableDock.player_current_lives[player_number] -= delta
			"multiply":
				new_balls *= modifier_value
				delta = new_balls - current_balls
				#VariableDock.player_current_lives[player_number] += delta
			"divide":
				if modifier_value != 0:
					new_balls = max(round(current_balls / modifier_value), 0)
					delta = current_balls - new_balls
					#VariableDock.player_current_lives[player_number] -= delta
				else:
					#print("Division by zero attempted")
					return
		
		# Update both balls and lives
		#removed this because i cannot apply twice in creation and death. currently t happens in player script at the proper time like after deletion. do not add something like this to sumo script as it is already handled in player script VariableDock.player_number_of_alive_balls[player_number] = new_balls 
		
		# Schedule creation/deletion
		if operation_type in ["add", "multiply"]:
			VariableDock.player_ball_scheduled_for_creation_count[player_number] += delta
		else:
			VariableDock.player_ball_scheduled_for_deletion_count[player_number] += delta
			
		#print("Player %d balls changed by %d via %s" % [player_number, delta, operation_type])

func calculate_radius_change(modifier_value: int) -> float:
	# Shared calculation for addition/subtraction
	var base_multiplier = 0.05
	var log_scale = 1.0
	var radius_change = base_multiplier * log(modifier_value + 1) * log_scale
	var min_change = 0.1 * modifier_value * 0.003
	return max(radius_change, min_change)
	
func reset_player_platforms_to_neutral(player_number: int):
	if player_number in player_platforms:
		# Create a copy of the array to avoid modification during iteration
		var platforms_to_reset = player_platforms[player_number].duplicate()
		
		for platform in platforms_to_reset:
			if is_instance_valid(platform):
				# Change material to neutral (player 0)
				change_material(platform, 0)
				# Remove any energy orbs on these platforms
				if platform in platform_energy_orbs:
					var orb = platform_energy_orbs[platform]
					if orb:
						orb.queue_free()
					platform_energy_orbs.erase(platform)
		
		# Clear the player's platform list
		player_platforms[player_number].clear()
		update_ui()
		#print("Reset all platforms for player ", player_number, " to neutral")



func _generate_spawn_points():
	asteroid_radius = new_radius * .9  # Spawn outside main stage area
	# Lowered height values to keep asteroids closer to ground level
	var number_of_positions_generated = asteroid_radius * 33 #more positions generated makes it look more natural * 33 is a lot but makes it accurate
	for height in [50, 55, 60]:  # Reduced from [15, 20, 25]
		for i in number_of_positions_generated:
			var angle = i * (360.0 / number_of_positions_generated)
			var distance = randf() * asteroid_radius  # Random distance between 0 and asteroid_radius
			var point = Vector3(
				distance * cos(deg_to_rad(angle)),
				height,
				distance * sin(deg_to_rad(angle))
				)
			spawn_points.append(point)
			
func asteroid_spawn():
	if asteroid_shower_trigger_mark == 1 and asteroid_shower_timer == null:
		asteroid_shower_timer = Timer.new()
		asteroid_shower_timer.wait_time = asteroid_shower_start_check_seconds_frequency # how often there is a chance of triggering a asteroid shower
		asteroid_shower_timer.one_shot = true
		asteroid_shower_timer.connect("timeout", Callable(self, "asteroid_shower_trigger"))
		add_child(asteroid_shower_timer)
		asteroid_shower_timer.start()
	if asteroid_spawn_timer == null and asteroid_shower_trigger_mark == 0:
		asteroid_spawn_timer = Timer.new()
		asteroid_spawn_timer.wait_time = asteroid_seconds_frequency # 7 seconds is how long energy orbs last
		asteroid_spawn_timer.one_shot = true
		asteroid_spawn_timer.connect("timeout", Callable(self, "asteroid_spawn_trigger"))
		add_child(asteroid_spawn_timer)
		asteroid_spawn_timer.start()
	if asteroid_shower_stop_timer == null and asteroid_shower_trigger_mark == 0:
		asteroid_shower_stop_timer = Timer.new()
		asteroid_shower_stop_timer.wait_time = length_of_asteroid_shower_seconds # 7 seconds is how long energy orbs last
		asteroid_shower_stop_timer.one_shot = true
		asteroid_shower_stop_timer.connect("timeout", Callable(self, "asteroid_shower_cancel_trigger"))
		add_child(asteroid_shower_stop_timer)
		asteroid_shower_stop_timer.start()

func asteroid_shower_cancel_trigger():
	asteroid_shower_stop_timer.stop()
	asteroid_shower_trigger_mark = 1
	asteroid_shower_stop_timer.queue_free()
	
func asteroid_shower_trigger():
	if asteroid_shower_trigger_mark == 1: 
		if randf() > .66: #50% chance of triggering an asteroid shower.
			asteroid_shower_trigger_mark = 0
			asteroid_shower_timer.stop()
			asteroid_shower_timer.queue_free()
			#print("Asteroid shower trigger")
			
func asteroid_spawn_trigger():
	asteroid_spawn_timer.stop()
	asteroid_spawn_timer = null
	var asteroid = ASTEROID_SCENE.instantiate()
	add_child(asteroid)
	
	if spawn_points.is_empty():
		_generate_spawn_points()
	
	asteroid.global_position = spawn_points[randi() % spawn_points.size()]
	var min_scale = 0.5
	var max_scale = 2.0
	asteroid.scale = Vector3(
		randf_range(min_scale, max_scale),
		randf_range(min_scale, max_scale),
		randf_range(min_scale, max_scale)
	)
	var asteroid_body = asteroid.get_node("RigidBody3D")
	if asteroid_body:
		#print("Setting up collision for:", asteroid_body.name)
		
		var connect_result = asteroid_body.body_entered.connect(
			func(body: Node):
				_on_asteroid_collision(body, asteroid_body)
		)
		
		if connect_result != OK:
			pass
			#print("Connection failed error code:", connect_result)
		else:
			asteroid_body.collision_layer = 4
			asteroid_body.collision_mask = 1 | 2
			asteroid_body.contact_monitor = true
			asteroid_body.max_contacts_reported = 10
			
			# Calculate random target position on the stage (Y=0)
			var target_radius = asteroid_radius
			var angle = randf() * 2 * PI
			var distance = randf() * target_radius
			var target_x = distance * cos(angle)
			var target_z = distance * sin(angle)
			var target_position = Vector3(target_x, 0, target_z)
			
			# Determine direction and apply impulse
			var direction = (target_position - asteroid.global_position).normalized()
			var impulse_strength = randf_range(10.0, 20.0)
			asteroid_body.apply_impulse(direction * impulse_strength)
	else:
		pass
		#print("Missing RigidBody3D node in:", asteroid.get_children())

func _on_asteroid_collision(body: Node, asteroid_body: RigidBody3D):
	#print("Collision between:", asteroid_body.name, "and", body.name)
	
	if body.is_in_group("ground"):
		_delete_platform(body)
		asteroid_body.queue_free()
	elif body.is_in_group("player"):
		# Add player impact logic here
		asteroid_body.queue_free()
