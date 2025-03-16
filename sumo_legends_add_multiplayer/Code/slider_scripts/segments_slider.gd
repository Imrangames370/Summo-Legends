extends HSlider


func _ready():
	# Initialize the slider value
	value = VariableDock.segments_number
	
func _on_value_changed(value):
	#at 9 segments that means 9 by 9 platforms totaling 81 platforms
	VariableDock.segments_number = value
	VariableDock.modifier_spawn_rate = value * 0.0003 * VariableDock.modifier_spawn_rate_adjuster
