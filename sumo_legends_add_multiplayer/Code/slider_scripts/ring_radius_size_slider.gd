extends HSlider

func _ready():
	# Initialize the slider value
	value = VariableDock.circle_radius
	
func _on_value_changed(value):
	VariableDock.circle_radius = value
