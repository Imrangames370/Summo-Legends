extends HSlider

func _on_value_changed(value):
	VariableDock.base_bounce_all_players = value
