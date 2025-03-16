extends CheckBox
#VariableDock

"""PLEASE KEEP IN MIND YOU MUST ENABLE THE PLATFORM CONTROL CHECKBOX AND PUSH START GAME TO SEE THESE LABELS DISPLAY
during_game_interface is set to visibility false on game start, then when u click start game it is set true,
 then when a game ends and they go back to main menu it is set false again. never want menu and during game interfaces showing at same time"""
#VariableDock.player_2_platforms_display

"""IGNORE NODE ERRORS. they only say that because its not visible on game start but it works perfectly despite errors."""

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


func _on_toggled(toggled_on: bool) -> void:
	if toggled_on:
		VariableDock.PlayerPlatformControl = 1
		print("PlayerPlatformControl on")
	else:
		VariableDock.PlayerPlatformControl = 0
		print("PlayerPlatformControl off")
