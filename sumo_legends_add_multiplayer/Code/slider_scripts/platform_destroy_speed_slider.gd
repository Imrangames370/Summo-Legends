extends HSlider

func _ready():
	# Initialize the slider value
	value = VariableDock.slider_disappearing_platform_seconds
	
func _on_value_changed(value):
	VariableDock.slider_disappearing_platform_seconds = value
