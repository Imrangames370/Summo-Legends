extends HSlider


func _ready():
	# Initialize the slider value
	value = VariableDock.energy_orb_spawn_rate
	
func _on_value_changed(value):
	VariableDock.energy_orb_spawn_rate = value
