extends Camera3D

@onready var top_down_camera_3d: Camera3D = $"."

@export var padding_factor: float = 1.25
@export var min_height: float = 60.0
@export var max_height: float = 7000.0
@export var smooth_speed: float = 10.0
@export var fov_degrees: float = 45.0

func _ready():
	top_down_camera_3d.make_current()
	projection = Camera3D.PROJECTION_PERSPECTIVE
	fov = fov_degrees

func _process(delta):
	# In the camera's _process function:
	var alive_players = []
	# Collect all sphere positions from alive players
	for i in range(VariableDock.player_alive.size()):
		if VariableDock.player_alive[i] == 2:
			var positions = VariableDock.player_transform_position[i]
			for pos in positions:
				if pos is Vector3 and pos != Vector3.ZERO:
					alive_players.append(pos)
	
	if alive_players.is_empty():
		return #skips unalive players

	# Calculate bounding box
	var min_x = INF
	var max_x = -INF
	var min_z = INF
	var max_z = -INF
	
	for pos in alive_players:
		min_x = min(min_x, pos.x)
		max_x = max(max_x, pos.x)
		min_z = min(min_z, pos.z)
		max_z = max(max_z, pos.z)
	
	var center_x = (min_x + max_x) / 2.0
	var center_z = (min_z + max_z) / 2.0
	var width = max_x - min_x
	var depth = max_z - min_z

	# Calculate required height
	var aspect_ratio = get_viewport().size.x / get_viewport().size.y
	var tan_half_fov = tan(deg_to_rad(fov_degrees / 2.0))
	
	var required_height_width = (width * padding_factor) / (2.0 * tan_half_fov * aspect_ratio)
	var required_height_depth = (depth * padding_factor) / (2.0 * tan_half_fov)
	var required_height = clamp(max(required_height_width, required_height_depth), min_height, max_height)

	# Smooth position update only
	var target_position = Vector3(center_x, required_height, center_z)
	position = position.lerp(target_position, delta * smooth_speed)
	
	# Maintain fixed rotation (remove any look_at() calls)
	rotation_degrees = Vector3(-90, -90, 0)  # Keep locked every frame
