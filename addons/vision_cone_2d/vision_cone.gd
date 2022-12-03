extends Node2D

# TODO rename to vision_cone_2d.gd

class_name VisionCone2D

# TODO add variable descriptions
@export_group("Raycast parameters")
@export var ray_count = 100
# TODO add value range
@export var angle_deg = 360
@export var max_distance = 500

@export_group("Collisions")
@export_flags_2d_physics var collision_layer_mask: int = 0
@export var write_collision_polygon: CollisionPolygon2D

@export_group("Visualization")
@export var write_polygon2d: Polygon2D
@export var debug_lines = false
@export var debug_shape = false

@export_group("Static optimization")
@export var recalculate_if_static = true
@export var static_threshold: float = 10

var _vision_points: Array[Vector2]
var _last_position = null

# constants for optimization
@onready var _angle = deg_to_rad(angle_deg)
@onready var _angle_half = _angle/2.
@onready var _angular_delta = _angle / ray_count

func _process(_delta: float) -> void:
	if debug_lines or debug_shape:
		queue_redraw()

func _physics_process(delta: float) -> void:
	recalculate_vision()

func recalculate_vision(override_static_flag = false):
	var position_has_changed = _last_position == null or (global_position - _last_position).length() > static_threshold
	var should_recalculate = override_static_flag or recalculate_if_static or position_has_changed
	if not should_recalculate:
		return

	_last_position = global_position
	_vision_points.clear()
	
	_optional_origin_point()
	for i in range(ray_count): 
		# TODO following transform should be customizable
		_ray_to(Vector2(0, max_distance).rotated(_angular_delta * i + get_parent().rotation - _angle_half))
	_optional_origin_point()
	
	_update_collision_polygon()
	_update_render_polygon()

func _draw():
	if len(_vision_points) == 0:
		return 
	var from = _vision_points[0]
	var to: Vector2
	for i in range(1, len(_vision_points)):
		to = _vision_points[i]
		if debug_shape:
			draw_line(from, to, Color.GREEN)
		if debug_lines:
			draw_line(Vector2.ZERO, to, Color.BLUE)
		from = to
	
func _update_collision_polygon():
	if write_collision_polygon == null:
		return
	write_collision_polygon.polygon.clear()
	var polygon = PackedVector2Array()
	polygon.append_array(_vision_points)
	write_collision_polygon.polygon = polygon

func _update_render_polygon():
	if write_polygon2d == null:
		return
	var polygon = PackedVector2Array(_vision_points);
	write_polygon2d.polygon = polygon

func _ray_to(direction: Vector2):
	# TODO add offset to origin
	var destination = global_position + direction
	var query = PhysicsRayQueryParameters2D.create(global_position, destination, collision_layer_mask)
	var collision = get_world_2d().direct_space_state.intersect_ray(query)

	var ray_position = collision["position"] if "position" in collision else destination
	_vision_points.append(to_local(ray_position))

func _optional_origin_point():
	if _angle < 2*PI:
		_vision_points.append(Vector2.ZERO)
