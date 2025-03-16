extends HSlider

# Called when the node enters the scene tree for the first time.
func _ready():
	value = VariableDock.main_stage_3d_camera_height
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_value_changed(value):
	VariableDock.main_stage_3d_camera_height = value
