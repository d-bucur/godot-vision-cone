extends Node2D

class_name VisionCone2D

@export_group("Raycast parameters")
@export var ray_count = 100
@export var angle = 2*PI  # TODO change to degrees
@export var max_distance = 500

@export_group("Collisions")
@export_flags_2d_physics var collision_layer_mask: int = 0
@export var write_collision_polygon: CollisionPolygon2D

@export_group("Visualization")
@export var write_polygon2d: Polygon2D
@export var debug_lines = false
@export var debug_shape = false

@export_group("Static optimization")
@export var recalculate_if_static = false
@export var static_threshold: float = 10

var _vision_points: Array[Vector2]
var _last_position = null

func _process(_delta: float) -> void:
	if debug_lines or debug_shape:
		queue_redraw()

func _physics_process(delta: float) -> void:
	recalculate_vision()

func recalculate_vision(override_static_flag = false):
	# TODO if angle is less than 360 need to draw points at beginning and end
	var position_has_changed = _last_position == null or (global_position - _last_position).length() > static_threshold
	if override_static_flag or recalculate_if_static or position_has_changed:
		_last_position = global_position
		_vision_points.clear()
		
		var angular_delta = angle / ray_count
		for i in range(ray_count): 
			_ray(Vector2(0, max_distance).rotated(angular_delta * i))
		
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

func _ray(direction: Vector2):
	var destination = global_position + direction
	var query = PhysicsRayQueryParameters2D.create(global_position, destination, collision_layer_mask)
	var collision = get_world_2d().direct_space_state.intersect_ray(query)

	var ray_position = collision["position"] if "position" in collision else destination
	_vision_points.append(to_local(ray_position))
