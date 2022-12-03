extends Node2D

# TODO rename to vision_cone_2d.gd

class_name VisionCone2D

@export_group("Raycast parameters")
## How wide the vision cone is in degrees
@export_range(0, 360) var angle_deg = 360
## Total number of rays that will be shot to cover the angle. Will be distributed at equal distances.
## This has the biggest impact on performance in the script.
## Have this high enough that it is precise, but low enough that it doesn't affect performance
@export var ray_count = 100
## The maximum length of the rays. Basically how far the character can see
@export var max_distance = 500.

@export_group("Collisions")
## What collision layers will block the vision. Have it set to the same layer as your walls, while avoiding things like items or characters
@export_flags_2d_physics var collision_layer_mask: int = 0
## Optional collision shape that the cone will be copied to.
## Use this if you want to have logic on things entering the cone (you probably do, unless you're just visualizing the cone without acting on it)
@export var write_collision_polygon: CollisionPolygon2D

@export_group("Visualization")
## Optional shape used to render the cone. This can then be textured and colored to customize the visual aspect
## Or it can be null if you don't need to visualize the cone, but maybe just use it for AI
@export var write_polygon2d: Polygon2D
## Will draw lines for each ray. Only used for debugging, you should probably disable it in the actual project
@export var debug_lines = false
## Will draw the shape outline of the cone. Only used for debugging, you should probably disable it in the actual project
@export var debug_shape = false

@export_group("Static optimization")
## Should the vision cone be recalculated when the object hasn't moved?
## Set this to false to optimize static objects that will never need to recalculate their vision, ie. static cameras
@export var recalculate_if_static = true
## How far the character has to move before the vision cone is recalculated. Only used if recalculate_if_static is false
@export var static_threshold: float = 2

var _vision_points: Array[Vector2]
var _last_position = null

# constants for optimization
@onready var _angle = deg_to_rad(angle_deg)
@onready var _angle_half = _angle/2.
@onready var _angular_delta = _angle / ray_count

func _process(_delta: float) -> void:
	if debug_lines or debug_shape:
		queue_redraw()

# TODO add param for minimum time before redraw
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
