extends Control

var set_skin_true = 1
@onready var _1_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P1_Material_Menu_Display_Viewport/1Material_Texture_Display_For_Viewport"
@onready var _2_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P2_Material_Menu_Display_Viewport/2Material_Texture_Display_For_Viewport"
@onready var _3_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P3_Material_Menu_Display_Viewport/3Material_Texture_Display_For_Viewport"
@onready var _4_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P4_Material_Menu_Display_Viewport/4Material_Texture_Display_For_Viewport"
@onready var _5_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P5_Material_Menu_Display_Viewport/5Material_Texture_Display_For_Viewport"
@onready var _6_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P6_Material_Menu_Display_Viewport/6Material_Texture_Display_For_Viewport"
@onready var _7_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P7_Material_Menu_Display_Viewport/7Material_Texture_Display_For_Viewport"
@onready var _8_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P8_Material_Menu_Display_Viewport/8Material_Texture_Display_For_Viewport"
@onready var _9_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P9_Material_Menu_Display_Viewport/9Material_Texture_Display_For_Viewport"
@onready var _10_material_texture_display_for_viewport: MeshInstance3D = $"../../../Viewports/P10_Material_Menu_Display_Viewport/10Material_Texture_Display_For_Viewport"


@onready var player_1_select_skin_button: Button = $Player_1_Select_Skin_Button
@onready var player_2_select_skin_button: Button = $Player_2_Select_Skin_Button
@onready var player_3_select_skin_button: Button = $Player_3_Select_Skin_Button
@onready var player_4_select_skin_button: Button = $Player_4_Select_Skin_Button
@onready var player_5_select_skin_button: Button = $Player_5_Select_Skin_Button
@onready var player_6_select_skin_button: Button = $Player_6_Select_Skin_Button
@onready var player_7_select_skin_button: Button = $Player_7_Select_Skin_Button
@onready var player_8_select_skin_button: Button = $Player_8_Select_Skin_Button
@onready var player_9_select_skin_button: Button = $Player_9_Select_Skin_Button
@onready var player_10_select_skin_button: Button = $Player_10_Select_Skin_Button

@onready var player_1_name_editor: LineEdit = $"../Player_1_Name_Editor"
@onready var player_2_name_editor: LineEdit = $"../Player_2_Name_Editor"
@onready var player_3_name_editor: LineEdit = $"../Player_3_Name_Editor"
@onready var player_4_name_editor: LineEdit = $"../Player_4_Name_Editor"
@onready var player_5_name_editor: LineEdit = $"../Player_5_Name_Editor"
@onready var player_6_name_editor: LineEdit = $"../Player_6_Name_Editor"
@onready var player_7_name_editor: LineEdit = $"../Player_7_Name_Editor"
@onready var player_8_name_editor: LineEdit = $"../Player_8_Name_Editor"
@onready var player_9_name_editor: LineEdit = $"../Player_9_Name_Editor"
@onready var player_10_name_editor: LineEdit = $"../Player_10_Name_Editor"



@onready var red_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/Red_Skin_Select_Button"
@onready var green_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/Green_Skin_Select_Button"
@onready var yellow_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/Yellow_Skin_Select_Button"
@onready var dark_blue_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/Dark_Blue_Skin_Select_Button"
@onready var orange_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/Orange_Skin_Select_Button"
@onready var purple_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/Purple_Skin_Select_Button"
@onready var white_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/White_Skin_Select_Button"
@onready var black_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/Black_Skin_Select_Button"
@onready var cyan_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/Cyan_Skin_Select_Button"
@onready var light_pink_skin_select_button: Button = $"../../Custom_Skin_Selection_Screen/Light_Pink_Skin_Select_Button"


@onready var game_base_screen: Control = $".."
@onready var settings: Control = $"../../Settings"
@onready var custom_skin_selection_screen: Control = $"../../Custom_Skin_Selection_Screen"
@onready var post_match_interface: Control = $"../../../Post-Match Interface"
@onready var background_menu: Control = $"../../../Background Menu"
@onready var during_game_interface: Control = $"../../../During Game Interface"

var set_display_material

func red_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.RED_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)

func green_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.GREEN_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)

func yellow_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.YELLOW_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)


func dark_blue_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.DARK_BLUE_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)


func orange_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.ORANGE_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)

func purple_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.PURPLE_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)

func white_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.WHITE_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)

func black_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.BLACK_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)
			
func cyan_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.CYAN_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)
			
func light_pink_skin_select_button_pressed():
			VariableDock.sphere_mesh_array[VariableDock.player_number_skin_selection].material = VariableDock.LIGHT_PINK_MATERIAL #sets material to player
			return_to_main_menu_after_skin_selection()
			print("VariableDock.player_number_skin_selection", VariableDock.player_number_skin_selection)
			
func return_to_main_menu_after_skin_selection():
		settings.visible = false
		game_base_screen.visible = true
		during_game_interface.visible = false
		background_menu.visible = true
		post_match_interface.visible = false
		custom_skin_selection_screen.visible = false

# GO TO SKIN SELECTION SCREEN
func move_to_skin_menu():
	settings.visible = false
	game_base_screen.visible = false
	during_game_interface.visible = false
	background_menu.visible = true
	post_match_interface.visible = false
	custom_skin_selection_screen.visible = true

func _enter_custom_skin_selection_10():
	VariableDock.player_number_skin_selection = 0
	move_to_skin_menu()
	
func _enter_custom_skin_selection_9():
	VariableDock.player_number_skin_selection = 9
	move_to_skin_menu()

func _enter_custom_skin_selection_8():
	VariableDock.player_number_skin_selection = 8
	move_to_skin_menu()
	
func _enter_custom_skin_selection_7():
	VariableDock.player_number_skin_selection = 7
	move_to_skin_menu()
	
func _enter_custom_skin_selection_6():
	VariableDock.player_number_skin_selection = 6
	move_to_skin_menu()
	
func _enter_custom_skin_selection_5():
	VariableDock.player_number_skin_selection = 5
	move_to_skin_menu()
	
func _enter_custom_skin_selection_4():
	VariableDock.player_number_skin_selection = 4
	move_to_skin_menu()
	
func _enter_custom_skin_selection_3():
	VariableDock.player_number_skin_selection = 3
	move_to_skin_menu()
	
func _enter_custom_skin_selection_2():
	VariableDock.player_number_skin_selection = 2
	move_to_skin_menu()
	
func _enter_custom_skin_selection_1():
	VariableDock.player_number_skin_selection = 1
	move_to_skin_menu()

func _ready():
			#set the buttons to be invisible by default.
			#every single time this function triggers though it is setting all buttons to not be visible. so only doing it once
			player_1_select_skin_button.visible = false
			player_2_select_skin_button.visible = false
			player_3_select_skin_button.visible = false
			player_4_select_skin_button.visible = false
			player_5_select_skin_button.visible = false
			player_6_select_skin_button.visible = false
			player_7_select_skin_button.visible = false
			player_8_select_skin_button.visible = false
			player_9_select_skin_button.visible = false
			player_10_select_skin_button.visible = false
			player_1_name_editor.visible = false
			player_2_name_editor.visible = false
			player_3_name_editor.visible = false
			player_4_name_editor.visible = false
			player_5_name_editor.visible = false
			player_6_name_editor.visible = false
			player_7_name_editor.visible = false
			player_8_name_editor.visible = false
			player_9_name_editor.visible = false
			player_10_name_editor.visible = false
			
func game_start_skin_button_defaults(player_number):
			if player_number == 1:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.RED_MATERIAL #reset actual player material to default
				_1_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.RED_MATERIAL) # reset viewport's mesh material to default
				#print("Setting Player 1 material:", VariableDock.RED_MATERIAL)
				
			if player_number == 2:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.GREEN_MATERIAL #reset actual player material to default
				_2_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.GREEN_MATERIAL) # reset viewport's mesh material to default
				#print("Setting Player 2 material:", VariableDock.GREEN_MATERIAL)
			if player_number == 3:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.YELLOW_MATERIAL #reset actual player material to default
				_3_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.YELLOW_MATERIAL) # reset viewport's mesh material to default
				
			if player_number == 4:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.DARK_BLUE_MATERIAL #reset actual player material to default
				_4_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.DARK_BLUE_MATERIAL) # reset viewport's mesh material to default
				
			if player_number == 5:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.ORANGE_MATERIAL #reset actual player material to default
				_5_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.ORANGE_MATERIAL) # reset viewport's mesh material to default
				
			if player_number == 6:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.PURPLE_MATERIAL #reset actual player material to default
				_6_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.PURPLE_MATERIAL) # reset viewport's mesh material to default
				
			if player_number == 7:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.WHITE_MATERIAL #reset actual player material to default
				_7_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.WHITE_MATERIAL) # reset viewport's mesh material to default
				
			if player_number == 8:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.BLACK_MATERIAL #reset actual player material to default
				_8_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.BLACK_MATERIAL) # reset viewport's mesh material to default
				
			if player_number == 9:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.LIGHT_PINK_MATERIAL #reset actual player material to default
				_9_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.LIGHT_PINK_MATERIAL) # reset viewport's mesh material to default
				
			if player_number == 0:
				VariableDock.sphere_mesh_array[player_number].material = VariableDock.CYAN_MATERIAL #reset actual player material to default
				_10_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.CYAN_MATERIAL) # reset viewport's mesh material to default
				
				
				#disable the button visibility
func custom_skin_preview_updating(player_number):
		if VariableDock.custom_skin_disable_enable_trigger[player_number] == 1:
			print("1 player_icons")
			#updating skins off
		if VariableDock.custom_skin_disable_enable_trigger[player_number] == 2:
			print("2 player_icons")
			#updating skins on
		if VariableDock.mark_player_connected[player_number] == 1: #dyanmically disable corresponding player button due to player being off.
			print("Mesh Skin Disable")
			if player_number == 1:
				player_1_select_skin_button.visible = false
				player_1_name_editor.visible = false
			elif player_number == 2:
				player_2_select_skin_button.visible = false
				player_2_name_editor.visible = false
			elif player_number == 3:
				player_3_select_skin_button.visible = false
				player_3_name_editor.visible = false
			elif player_number == 4:
				player_4_select_skin_button.visible = false
				player_4_name_editor.visible = false
			elif player_number == 5:
				player_5_select_skin_button.visible = false
				player_5_name_editor.visible = false
			elif player_number == 6:
				player_6_select_skin_button.visible = false
				player_6_name_editor.visible = false
			elif player_number == 7:
				player_7_select_skin_button.visible = false
				player_7_name_editor.visible = false
			elif player_number == 8:
				player_8_select_skin_button.visible = false
				player_8_name_editor.visible = false
			elif player_number == 9:
				player_9_select_skin_button.visible = false
				player_9_name_editor.visible = false
			elif player_number == 0:
				player_10_select_skin_button.visible = false
				player_10_name_editor.visible = false
				
		if VariableDock.mark_player_connected[player_number] == 2: #dyanmically disable corresponding player button due to player being off.
			print("Mesh Skin Enable")
			if player_number == 1:
				player_1_select_skin_button.visible = true
				player_1_name_editor.visible = true
			elif player_number == 2:
				player_2_select_skin_button.visible = true
				player_2_name_editor.visible = true
			elif player_number == 3:
				player_3_select_skin_button.visible = true
				player_3_name_editor.visible = true
			elif player_number == 4:
				player_4_select_skin_button.visible = true
				player_4_name_editor.visible = true
			elif player_number == 5:
				player_5_select_skin_button.visible = true
				player_5_name_editor.visible = true
			elif player_number == 6:
				player_6_select_skin_button.visible = true
				player_6_name_editor.visible = true
			elif player_number == 7:
				player_7_select_skin_button.visible = true
				player_7_name_editor.visible = true
			elif player_number == 8:
				player_8_select_skin_button.visible = true
				player_8_name_editor.visible = true
			elif player_number == 9:
				player_9_select_skin_button.visible = true
				player_9_name_editor.visible = true
			elif player_number == 0:
				player_10_select_skin_button.visible = true
				player_10_name_editor.visible = true
				
		if VariableDock.mark_player_connected[player_number] == 2 and VariableDock.custom_skin_disable_enable_trigger[player_number] == 2:
			print("Mesh Skin Preview Player Number: ", player_number)
			if player_number == 1:
				player_1_select_skin_button.visible = true
				print("active custom updating. player: ", player_number)
				_1_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
			if player_number == 2:
				player_2_select_skin_button.visible = true
				print("active custom updating. player: ", player_number)
				_2_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
			if player_number == 3:
				player_3_select_skin_button.visible = true
				_3_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
			if player_number == 4:
				player_4_select_skin_button.visible = true
				_4_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
			if player_number == 5:
				player_5_select_skin_button.visible = true
				_5_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
			if player_number == 6:
				player_6_select_skin_button.visible = true
				_6_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
			if player_number == 7:
				player_7_select_skin_button.visible = true
				_7_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
			if player_number == 8:
				player_8_select_skin_button.visible = true
				_8_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
			if player_number == 9:
				player_9_select_skin_button.visible = true
				_9_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
			if player_number == 0:
				player_10_select_skin_button.visible = true
				_10_material_texture_display_for_viewport.mesh.surface_set_material(0, VariableDock.sphere_mesh_array[player_number].material)
