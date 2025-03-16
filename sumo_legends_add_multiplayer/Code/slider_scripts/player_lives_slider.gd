extends HSlider
#global name: VariableDock


func _ready():
	# Initialize the slider value
	value = VariableDock.game_start_player_lives
	
func _on_value_changed(value):
	VariableDock.game_start_player_lives = value
	print("VariableDock.player_lives", VariableDock.game_start_player_lives)
