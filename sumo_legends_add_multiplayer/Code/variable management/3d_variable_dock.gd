extends Node3D
#VariableDock on autoloader

# var  player keyboard cycle count for simply telling the label only.

@onready var player_main_keyboard: Node3D = $"../Player_Manager/Player_Main_Keyboard" #ignore warning it just takes a bit to load in on game start. please keep this
@onready var second_player_keyboard: Node3D = $"../Player_Manager/Second_Player_Keyboard" #ignore warning it just takes a bit to load in on game start. please keep this
@onready var player_1_controller: Node3D = $"../Player_Manager/Player_1_Controller"
@onready var player_2_controller: Node3D = $"../Player_Manager/Player_2_Controller"
@onready var player_3_controller: Node3D = $"../Player_Manager/Player_3_Controller"
@onready var player_4_controller: Node3D = $"../Player_Manager/Player_4_Controller"
@onready var player_5_controller: Node3D = $"../Player_Manager/Player_5_Controller"
@onready var player_6_controller: Node3D = $"../Player_Manager/Player_6_Controller"
@onready var player_7_controller: Node3D = $"../Player_Manager/Player_7_Controller"
@onready var player_8_controller: Node3D = $"../Player_Manager/Player_8_Controller"

var reset_primary_custom_stage_tracker = 1 #essential for resetting primary custom stage when doing rematch or main menu in post match screen
var player_number_of_winner: int
var match_end: int = 0
var rematch_button_trigger: int = 1 # 1 means not triggered. 2 means triggered.
var game_in_play # 1 means not triggered. 2 means triggered.
var player_1_name_text: String = "Player 1"
var player_2_name_text: String = "Player 2"
var player_3_name_text: String = "Player 3"
var player_4_name_text: String = "Player 4"
var player_5_name_text: String = "Player 5"
var player_6_name_text: String = "Player 6"
var player_7_name_text: String = "Player 7"
var player_8_name_text: String = "Player 8"
var player_9_name_text: String = "Player 9"
var player_10_name_text: String = "Player 10"
var stealth_enabled = 1 #setting for he stealth checkbox. is 1 which means turned on by default unless turned off

var buy_options = []  # Array of arrays for each player's buy options
var sell_options = []  # Array of arrays for each player's sell options
var buyer_current_energy = []
var seller_current_energy = []
var player_buy_transaction_clear_menu_trigger = []

#player creation
var initial_player_creation = []
var enable_player = []
var device_to_player = {}  # Maps device IDs to player numbers

#for custom skin materials working in menu and for players
@onready var sphere_mesh_array = []
var player_number_skin_selection
var custom_skin_disable_enable_trigger = [] # 1 is disabled. 2 is enabled. so if value is 1 the custom skin preview button will not show. 
const GREEN_MATERIAL = preload("res://Assets/player_solid_color_skins/green_material.tres")
const RED_MATERIAL = preload("res://Assets/player_solid_color_skins/red_material.tres")
const YELLOW_MATERIAL = preload("res://Assets/player_solid_color_skins/yellow_material.tres")
const DARK_BLUE_MATERIAL = preload("res://Assets/player_solid_color_skins/dark_blue_material.tres")
const ORANGE_MATERIAL = preload("res://Assets/player_solid_color_skins/orange_material.tres")
const PURPLE_MATERIAL = preload("res://Assets/player_solid_color_skins/purple_material.tres")
const WHITE_MATERIAL = preload("res://Assets/player_solid_color_skins/white_material.tres")
const BLACK_MATERIAL = preload("res://Assets/player_solid_color_skins/black_material.tres")
const LIGHT_PINK_MATERIAL = preload("res://Assets/player_solid_color_skins/light_pink_material.tres")
const CYAN_MATERIAL = preload("res://Assets/player_solid_color_skins/cyan_material.tres")
const TRANSPARENT_MATERIAL = preload("res://Assets/player_solid_color_skins/transparent_material.tres")

var keyboard_player_9 = 1
var keyboard_player_8 = 1

"""DEATH DETECTION NEW"""
var player_death_status #not used i think?
var alive_players #not used i think?
var player_alive = []
var mark_player_connected = [] # A SEPERATE MARK FROM ENABLE_PLAYER FOR SHOWING PLAYER IS CURRENTLY CONNECTED. USED TO MAKE SURE THE SKIN DISPLAY WORKS EVEN WHEN PLAYER IS DEAD. AS PREVIOUSLY USING ENABLE_PLAYER WHEN PLAYER IS DEAD IT WOULDNT SHOW SKINS IN MAIN MENU WHICH IS A ISSUE
var count = 0
var timer: Timer
var timer_reset_on_rematch = 1
"""DEATH DETECTION END"""

"""DYNAMIC CAMERA 3D START"""
var player_transform_position = []
"""DYNAMIC CAMERA 3D END"""
"""PLAYER STATS START"""
var base_bounce_all_players: float = 1 # bounce for all players. 1 by default makes collisions better and leads to constant bouncing. makes more chaotic.
var base_jump_modifier_all_players: float = 800 #normal tap jump modifier like touching space bar once
var base_empowered_jump_modifier_multiplier_all_players: float = 1 #a seperate jump modifier for the empowered jump, the double tap one that consumes energy
var player_dash_force_multiplier: float = 25
"""PLAYER STATS END"""

"""SLIDER ADJUSTING START"""
var segments_number = 9
var circle_radius = 45
var main_stage_3d_camera_height = 50 #may not be being used currently but keep as i have slider already setup incase i wanna use it  in future
var slider_disappearing_platform_seconds = 3
var slider_random_chance_odds = 100
var energy_orb_spawn_rate = 0.007
var PlayerPlatformControl = 1
var Rotating: int = 0
var random_degrees_x: int = 0
var random_degrees_y: int = 0
var random_degrees_z: int = 0
var Degrees_Type: int = 0  # 0 for no degrees type
"""SLIDER ADJUSTING END"""

"""PLATFORM DISPLAY START"""
var player_1_platforms_display: int = 0
var player_2_platforms_display: int = 0
var player_3_platforms_display: int = 0
var player_4_platforms_display: int = 0
var player_5_platforms_display: int = 0
var player_6_platforms_display: int = 0
var player_7_platforms_display: int = 0
var player_8_platforms_display: int = 0
var player_9_platforms_display: int = 0
var player_10_platforms_display: int = 0
"""PLATFORM DISPLAY END"""

"""NEW PLAYER HELP START"""
var mark_player_connected_count = 0 #must be seperate count from count from alive playersotherwise they would add to each other and give innaccruate nubmers
"""NEW PLAYER HELP END"""
var first_run = 1 #used for EULA

"""PLAYER MASS. RADIUS. HEIGHT. NUMBER OF BALLS START"""
#use an array so u can append the default value on match start but each player can change their individual value mid game and you can reset it on rematch for all players to default
var player_radius = []
var player_update_modifier = [] 
var modifier_spawn_rate = 0.002 #0.002. do not change gets modified by segments slider anyway this variable just ensures spawn rate scales with number of platforms.
var modifier_spawn_rate_adjuster = 1 #what u actually adjust to raise spawn rate. 1 by default
#player mass is based on player radius as well in the player script
#player height is player_radius x 2, so you do not need a variable for it. 
#collision shape is player_radius + .1

var player_number_of_alive_balls = [] #needed so that multiplier or division when applying modifier knows how much balls to multiply or divide
var player_ball_scheduled_for_creation_count = [] 
var player_ball_scheduled_for_deletion_count = []
var player_current_lives = [] #necessary as i gotta update the player_current_lives for each player whenever a new ball gets added or dies.
var game_start_player_lives = 1 #modified via slider. should be used to reset player lives after rematch

"""PLAYER MASS. RADIUS. HEIGHT. NUMBER OF BALLS END"""

func calculate_added_players():
	mark_player_connected_count = 0
	for num in mark_player_connected:
		if num == 2:
			mark_player_connected_count += 1

func calculate_alive_players():
	count = 0 #reset count before making a new count
	for num in player_alive:
		if num == 2:
			count += 1
			#print("checking for alive players. count: ", count)
			if VariableDock.game_in_play == 2:
				create_timer(1) #waits for 1 seconds to trigger count check on match start. that way it does not instantly trigger rematch due to seeing count is 0 at first
func create_timer(duration: float):
	timer = Timer.new()
	timer.wait_time = duration
	timer.one_shot = true  # Timer runs only once
	timer.timeout.connect(_on_timer_timeout)
	add_child(timer)  # Add the timer to the current node
	timer.start()

func _on_timer_timeout():
			timer.stop()
			timer.start()
			if count == 0 and VariableDock.game_in_play == 2:
				#print("There is exactly zero element equal to 2") #ensures surviving player gets deleted before match end gets triggered
				VariableDock.match_end = 1
				VariableDock.reset_primary_custom_stage_tracker = 0
				#print("match end triggered. count: ", count)
	
func _ready():
	#print("Player_Main_Keyboard ready:", player_main_keyboard)
	#print("Second_Player_Keyboard ready:", second_player_keyboard)
	for i in range(10):  # Assuming 10 players
		buy_options.append([])
		sell_options.append([])
		buyer_current_energy.append(100)
		seller_current_energy.append(100)
		player_buy_transaction_clear_menu_trigger.append(0)  # Initialize with integers (e.g., 0)
		initial_player_creation.append(2)  # Initialize with integers (e.g., 0)
		enable_player.append(1)  # Initialize with integers (e.g., 0)
		#for custom skin materials working in menu and for players
		var sphere_mesh = SphereMesh.new()
		sphere_mesh_array.append(sphere_mesh)
		custom_skin_disable_enable_trigger.append(2)
		player_alive.append(0) #value is 1 by default which means not registered.
		mark_player_connected.append(1) #DO NOT RESET ON REMATCH. RESETTING ON REMATCH WOULD MAKE SKIN DISPLAY IN MAIN MENU STOP WORKING AFTER A REMATCH. value is 1 by default which means not connected.
		player_transform_position.append([])
		player_radius.append(1.5)
		player_number_of_alive_balls.append(1)
		player_current_lives.append(VariableDock.game_start_player_lives) #must be variable dock as this will be updated in other scripts. if not variabledock. it will not work
		player_update_modifier.append(0) # 0 by default. 1 is off. 2 is schedule for activation via physics process in player script
		player_ball_scheduled_for_creation_count.append(0)
		player_ball_scheduled_for_deletion_count.append(0)

func _process(delta):
		calculate_added_players()
		calculate_alive_players()
		
func rematch_reset_variable_dock(): # Called via sumo section ring script upon match reset
	#reset players themselves, necessary for letting it so players can create next round otherwise it breaks whole game if this isnt reset
	initial_player_creation.clear()
	enable_player.clear()
	# Reset buy and sell options
	buy_options.clear()
	sell_options.clear()
	timer_reset_on_rematch = 1
	# Reset energy values
	buyer_current_energy.clear()
	seller_current_energy.clear()
	player_alive.clear() #value is 1 by default which means not registered.
	# Reset transaction triggers
	player_buy_transaction_clear_menu_trigger.clear()
	player_transform_position.clear()
	#reset custom menu triggers
	custom_skin_disable_enable_trigger.clear()
	player_radius.clear()
	player_number_of_alive_balls.clear()
	player_update_modifier.clear()
	player_current_lives.clear() 
	player_ball_scheduled_for_creation_count.clear()
	player_ball_scheduled_for_deletion_count.clear()
	# Reinitialize arrays for all players (assuming 8 players)
	for i in range(10):
		buy_options.append([])
		sell_options.append([])
		player_alive.append(0) #value is 1 by default which means not registered.
		buyer_current_energy.append(100)  # Default energy
		seller_current_energy.append(100)  # Default energy
		player_buy_transaction_clear_menu_trigger.append(0)  # Default trigger
		initial_player_creation.append(2)  # Initialize with integers (e.g., 0)
		enable_player.append(1)  # Initialize with integers (e.g., 0)
		#for custom skin materials working in menu and for players
		var sphere_mesh = SphereMesh.new()
		sphere_mesh_array.append(sphere_mesh)
		custom_skin_disable_enable_trigger.append(2)
		player_transform_position.append([])
		player_radius.append(1.5)
		player_number_of_alive_balls.append(1)
		player_current_lives.append(VariableDock.game_start_player_lives) #must be variable dock as this will be updated in other scripts. if not variabledock. it will not work
		player_update_modifier.append(0) # 0 by default. 1 is off. 2 is schedule for activation via physics process in player script
		player_ball_scheduled_for_creation_count.append(0)
		player_ball_scheduled_for_deletion_count.append(0)
	#print("VariableDock reset to default values.")
