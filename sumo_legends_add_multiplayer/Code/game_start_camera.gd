extends Camera2D

"""EXTENDS CAMERA2D SO U CANNOT USE THIS TO TRIGGER 3D CAMERAS"""
@onready var start_menu_screen_camera: Camera2D = $"."
# ALL NODES IN MENU USER INTERFACE
@onready var during_game_interface: Control = $"../During Game Interface"
@onready var post_match_interface: Control = $"../Post-Match Interface"
@onready var victor_label: Label = $"../Post-Match Interface/Victor_Label"
@onready var settings: Control = $"../Menu_User_Interface/Settings"
@onready var game_base_screen: Control = $"../Menu_User_Interface/Game_Base_Screen"
@onready var background_menu: Control = $"../Background Menu"
@onready var custom_skin_selection_screen: Control = $"../Menu_User_Interface/Custom_Skin_Selection_Screen"

@onready var player_1_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_1_Select_Skin_Button"
@onready var player_2_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_2_Select_Skin_Button"
@onready var player_3_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_3_Select_Skin_Button"
@onready var player_4_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_4_Select_Skin_Button"
@onready var player_5_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_5_Select_Skin_Button"
@onready var player_6_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_6_Select_Skin_Button"
@onready var player_7_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_7_Select_Skin_Button"
@onready var player_8_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_8_Select_Skin_Button"
@onready var player_9_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_9_Select_Skin_Button"
@onready var player_10_select_skin_button: Button = $"../Menu_User_Interface/Game_Base_Screen/Player_Skin_Interface_Base_Screen/Player_10_Select_Skin_Button"
@onready var guide: Control = $"../Menu_User_Interface/Guide"
@onready var player_connect_guide: Control = $"../Menu_User_Interface/Player Connect Guide"
@onready var player_connect_guide_text: Label = $"../Menu_User_Interface/Player Connect Guide/Player_Connect_Guide_Text"
@onready var player_connect_guide_text_part_2: Label = $"../Menu_User_Interface/Player Connect Guide/Player_Connect_Guide_Text_Part_2"
@onready var player_controls_guide: Control = $"../Player Controls Guide"
@onready var player_controls_guide_text: Label = $"../Player Controls Guide/Player_Controls_Guide_Text"
@onready var new_player_helper: Label = $"../Menu_User_Interface/Game_Base_Screen/New_Player_Helper"
@onready var first_run_screen: Control = $"../Menu_User_Interface/First_Run_Screen"


func _go_to_base_screen_upon_eula_agree():
		VariableDock.first_run = 2
		first_run_screen.visible = false
		settings.visible = false
		game_base_screen.visible = true
		background_menu.visible = true
		during_game_interface.visible = false
		post_match_interface.visible = false
		custom_skin_selection_screen.visible = false
		player_connect_guide.visible = false
		guide.visible = false
		player_connect_guide_text.visible = false
		player_connect_guide_text_part_2.visible = false
		player_controls_guide_text.visible = false
		player_controls_guide.visible = false
		
func _ready():
	VariableDock.game_in_play = 1  # GAME IS NOT IN PLAY
	start_menu_screen_camera.make_current()
	if VariableDock.first_run == 1:
		first_run_screen.visible = true
		settings.visible = false
		game_base_screen.visible = false
		background_menu.visible = true
		during_game_interface.visible = false
		post_match_interface.visible = false
		custom_skin_selection_screen.visible = false
		player_connect_guide.visible = false
		guide.visible = false
		player_connect_guide_text.visible = false
		player_connect_guide_text_part_2.visible = false
		player_controls_guide_text.visible = false
		player_controls_guide.visible = false
	if VariableDock.first_run == 2:
		#installed device has accepted EULA previously.
		#print("Menu camera is now the active camera.")
		first_run_screen.visible = false
		settings.visible = false
		game_base_screen.visible = true
		background_menu.visible = true
		during_game_interface.visible = false
		post_match_interface.visible = false
		custom_skin_selection_screen.visible = false
		player_connect_guide.visible = false
		guide.visible = false
		player_connect_guide_text.visible = false
		player_connect_guide_text_part_2.visible = false
		player_controls_guide_text.visible = false
		player_controls_guide.visible = false
		
func _go_back_to_main_menu_from_post_game():
	VariableDock.game_in_play = 1 
	VariableDock.reset_primary_custom_stage_tracker = 0
	VariableDock.match_end = 0  # Reset match end state
	VariableDock.player_number_of_winner = -1 #reset player number of winner
	VariableDock.rematch_button_trigger = 2 #sets a rematch trigger for communicating to reset all players
	# GAME IS NO LONGER IN PLAY. myst be done last otherwise nothing else will trigger
	#LATER I WILL REMOVE THIS rematch_button_trigger WHEN CLICKING GO TO MAIN MENU AS SPHERES WILL ONLY GENERATE WHEN U CLICK
	#START GAME OR INNITIALIZE A PLAYER INTO THE GAME LIKE CONNECT A CONTROLLER OR PRESS A KEY FOR THE PLAYER U WANNA ADD
	#its just a bit complex to add something to fully reset player interaction until a certain key is pressed... i'd have to add a
	#if statement with a variable that is set to 0 when the key has not been pressed at least once. once pressed variable turns to 1
	#if variable is 1, the function runs. i think thats the only way.
	settings.visible = false
	game_base_screen.visible = true
	background_menu.visible = true
	during_game_interface.visible = false
	post_match_interface.visible = false
	custom_skin_selection_screen.visible = false
	guide.visible = false
	player_connect_guide.visible = false
	player_connect_guide_text.visible = false
	player_connect_guide_text_part_2.visible = false
	player_controls_guide_text.visible = false
	player_controls_guide.visible = false
	#print("Going back to the main menu.")
# Handles the rematch transition
func _go_rematch():
	#print("Rematch triggered.")
	VariableDock.game_in_play = 2  # GAME IS IN PLAY
	VariableDock.match_end = 0  # Reset match end state
	VariableDock.rematch_button_trigger = 2 #sets a rematch trigger for communicating to reset all players
	VariableDock.player_number_of_winner = -1 #reset player number of winner
	settings.visible = false
	game_base_screen.visible = false
	background_menu.visible = false
	during_game_interface.visible = true
	post_match_interface.visible = false
	custom_skin_selection_screen.visible = false
	guide.visible = false
	player_connect_guide.visible = false
	player_connect_guide_text.visible = false
	player_connect_guide_text_part_2.visible = false
	player_controls_guide_text.visible = false
	player_controls_guide.visible = false
	get_tree().call_group("PlayerManager", "reset_all_players_for_rematch")
	start_menu_screen_camera.make_current()
	
	### BREAK DEATH REMATCH CODE END

func _process(_delta):
		_activate_post_match_interface()
		new_player_connect_helper()
func new_player_connect_helper():
	if VariableDock.mark_player_connected_count == 0 and VariableDock.game_in_play == 1:
							new_player_helper.visible = true
							new_player_helper.text = """No players connected. Learn controls and connect by clicking help."""
							#print(VariableDock.mark_player_connected_count, "mark_player_connected_count")
	else:
							new_player_helper.visible = false
							new_player_helper.text = ""
							#print(VariableDock.mark_player_connected_count, "mark_player_connected_count")
	#based on player number, assign the skin upon pressing button.
func _start_game_from_main_menu():
	VariableDock.game_in_play = 2 # GAME IS IN PLAY
	#print(VariableDock.game_in_play, "start game VariableDock.game_in_play")
	#print("start game run")
	settings.visible = false
	game_base_screen.visible = false
	during_game_interface.visible = true
	background_menu.visible = false
	post_match_interface.visible = false
	custom_skin_selection_screen.visible = false
	# Change to a new scene using its file path
	#disabling 2d camera was not working so i just set the user interface node invisible.
	#works quite well, easy to enable and disable the menu now.
	start_menu_screen_camera.make_current()
	guide.visible = false
	player_connect_guide.visible = false
	player_connect_guide_text.visible = false
	player_connect_guide_text_part_2.visible = false
	player_controls_guide_text.visible = false
	player_controls_guide.visible = false

func _go_primary_settings_screen():
	VariableDock.game_in_play = 1  # GAME IS NOT IN PLAY
	settings.visible = true
	game_base_screen.visible = false
	background_menu.visible = true
	during_game_interface.visible = false
	post_match_interface.visible = false
	custom_skin_selection_screen.visible = false
	guide.visible = false
	player_connect_guide.visible = false
	player_connect_guide_text.visible = false
	player_connect_guide_text_part_2.visible = false
	player_controls_guide_text.visible = false
	player_controls_guide.visible = false
	
func _go_player_controls_guide_screen():
	VariableDock.game_in_play = 1  # GAME IS NOT IN PLAY
	settings.visible = false
	game_base_screen.visible = false
	background_menu.visible = true
	during_game_interface.visible = false
	post_match_interface.visible = false
	custom_skin_selection_screen.visible = false
	guide.visible = false
	player_connect_guide.visible = false
	player_connect_guide_text.visible = false
	player_connect_guide_text_part_2.visible = false
	player_controls_guide.visible = true
	player_controls_guide_text.visible = true
	player_controls_guide_text.text = """KEYBOARD
	PLAYER 1 KEYBOARD
	WASD MOVEMENT
	Jump = Spacebar
	Stealth = Q 
	Platform Menu Navigate = E
	Platform Menu Confirm = Left Side Shift + E
	RAM = Press the same move key 3 times.
	Double Jump = Press the jump key 3 times.
	Rally = Q
	
	Player 2 Keyboard
	ARROW KEY MOVEMENT
	Jump = ENTER
	STEALTH = / (THE SLASH WITH THE QUESTION MARK)
	Platform Menu Navigate = CTRL
	Platform Menu Confirm = Right Side Shift + CTRL
	RAM = Press the same move key 3 times.
	Double Jump = Press the jump key 3 times.
	Rally = ' 
	
	CONTROLLER
	Left joystick for all movement.
	stealth = B XBOX. SONY CIRCLE. NINTENDO A.
	jump = A XBOX. SONY X. NINTENDO B.
	Platform Menu Navigate = Sony Triangle. Xbox Y. Nintendo X.
	Platform Menu Confirm = Sony Triangle or Xbox Y or Nintendo X + RIGHT BUMPER
	RAM = Press the same move direction with left joystick 3 times.
	Double Jump = Press jump 3 times.
	Rally = XBOX X. SONY SQUARE. NINTENDO Y."""
	
func _go_player_connect_guide_screen():
	VariableDock.game_in_play = 1  # GAME IS NOT IN PLAY
	settings.visible = false
	game_base_screen.visible = false
	background_menu.visible = true
	during_game_interface.visible = false
	post_match_interface.visible = false
	custom_skin_selection_screen.visible = false
	guide.visible = false
	player_connect_guide.visible = true
	player_connect_guide_text.text = """! * * *Once the device is connected through bluetooth, plugged in, or if you are using keyboard:
* the player can be activated in game by moving around the left joystick, WASD or keyboard arrow keys. * * * !

* TO CONNECT PROPERLY, ALL PLAYERS MUST BE CONNECTED BEFORE STARTING UP THE GAME.
Nintendo does not offer much computer controller compatibility. However, below are the reccomendations for those with no other option. 
Nintendo controls are set up. If you find a way to connect a nintendo device, by plugging in or bluetooth, it will work. 
* Unlikely to work with Joycons, as you need both a left joystick and the ABYX buttons, unless using the Joy Con Connector then pairing with bluetooth. 
* Pro controller: Attempt to connect charging cable to controller to computer. Option 2: Attempt to connect via bluetooth.

Xbox Controllers (One/Series X|S)
Wired Connection (All Xbox Controllers):
1. Use a USB-C cable (Series X|S) or micro-USB cable (Xbox One).
2. Plug the controller into your device's USB port.
3. It will auto-detect (no setup needed on Windows/macOS).

Wireless (Bluetooth):
1. Works for Xbox Series X|S and Xbox One (model 1708+):
2. Turn on the controller by pressing the Xbox button.
3. Hold the Pairing Button (top edge) until the Xbox logo flashes rapidly.

Bluetooth on your device:
* Windows: Go to Settings > Bluetooth & devices > Add device > Bluetooth.
* macOS: Go to System Preferences > Bluetooth. Select "Xbox Wireless Controller" from the list.

PlayStation Controllers (DualShock 4/PS4 or DualSense/PS5) Wired Connection:
1. Use a USB-C cable (PS5 DualSense) or micro-USB cable (PS4 DualShock 4).
2. Using the cable, plug the controller into your device. It will work instantly on most systems.

Wireless for PS4 (DualShock 4):
1. Hold the PS Button + Share Button until the light bar flashes.

Wireless for PS5 (DualSense):
1. Hold the PS Button + Create Button (⋯) until the light bar flashes.

Wireless Playstation on your device:
* Windows: Go to Settings > Bluetooth & devices > Add device > Bluetooth.
* macOS: Go to System Preferences > Bluetooth.
* Select "Wireless Controller" (PS4) or "DualSense Wireless Controller" (PS5)."""
	player_connect_guide_text_part_2.text = """* During testing bluetooth, we found one must remove the controller device in the bluetooth settings by selecting remove device.
* This must be done every time before trying to connect the controller. Otherwise it will flicker connect or not connect at all.
* Bluetooth has a maximium distance of 30 feet.

Can play with 1 or 2 players on keyboard alongside muiltple controller players, or with only keyboard, or with only controller. 
Compatibility Notes:
* Windows: Xbox controllers work natively.
* PlayStation controllers may require third-party tools like DS4Windows for full functionality.
* macOS: Both controllers work over Bluetooth but may have limited button mapping in games.
* Linux: Both controllers are supported, but check game-specific compatibility.

Troubleshooting:
Not Pairing?:
* Ensure the controller is charged (use USB if low battery).
* Restart Bluetooth on your device.
* Update controller firmware via a console or PC app.

Input Lag?:
* Use a wired connection for better responsiveness.

PS5 DualSense Features:
* Haptic feedback/adaptive triggers only work in supported games (e.g., via USB on Windows)."""
	player_connect_guide_text.visible = true
	player_connect_guide_text_part_2.visible = true
	player_controls_guide.visible = false
func _go_guide_screen():
	VariableDock.game_in_play = 1  # GAME IS NOT IN PLAY
	settings.visible = false
	game_base_screen.visible = false
	background_menu.visible = true
	during_game_interface.visible = false
	post_match_interface.visible = false
	custom_skin_selection_screen.visible = false
	guide.visible = true
	player_connect_guide.visible = true
	player_connect_guide_text.visible = false
	player_connect_guide_text_part_2.visible = false
	player_controls_guide_text.visible = false
	player_controls_guide.visible = false
func _go_back_to_main_menu_from_settings():
	VariableDock.game_in_play = 1  # GAME IS NOT IN PLAY
#important to have it seperated so u dont gotta add VariableDock.match_end = 0. it does not need to be applied here. needlessly applying
#it may cause issues and is just in general a bad code practice,
	settings.visible = false
	game_base_screen.visible = true
	background_menu.visible = true
	during_game_interface.visible = false
	post_match_interface.visible = false
	custom_skin_selection_screen.visible = false
	guide.visible = false
	player_connect_guide.visible = false
	player_connect_guide_text.visible = false
	player_connect_guide_text_part_2.visible = false
	player_controls_guide_text.visible = false
	player_controls_guide.visible = false
# Handles the transition to the main menu

# Activates the post-match interface
func _activate_post_match_interface():
	if VariableDock.match_end == 1:
		VariableDock.game_in_play = 1  # GAME IS NO LONGER IN PLAY
		#print("Set to post match view")
		settings.visible = false
		game_base_screen.visible = false
		during_game_interface.visible = false
		post_match_interface.visible = true
		background_menu.visible = false
		custom_skin_selection_screen.visible = false
		guide.visible = false
		player_connect_guide.visible = false
		player_connect_guide_text.visible = false
		player_connect_guide_text_part_2.visible = false
		player_controls_guide_text.visible = false
		player_controls_guide.visible = false
		if VariableDock.player_number_of_winner == 0:
			victor_label.text = "Player 10 Won!"
		else:
			victor_label.text = "Player " + str(VariableDock.player_number_of_winner) + " Won!"


func _on_multiplayer_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/LobbyScreen.tscn")
