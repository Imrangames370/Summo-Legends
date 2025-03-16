extends HSlider

func _ready():
	# Initialize the slider value
	value = VariableDock.slider_random_chance_odds
	
func _on_value_changed(value):
	VariableDock.slider_random_chance_odds = value
