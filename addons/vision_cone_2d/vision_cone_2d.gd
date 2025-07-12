extends Node2D

## A configurable vision cone for 2D entities. It can be used for example to simulate the vision of enemies in a stealth game.
class_name VisionCone2D

@export_group("Raycast parameters")
## How wide the vision cone is in degrees
@export_range(0, 360) var angle_deg: int = 360
## Total number of rays that will be shot to cover the angle. Will be distributed at equal distances.
## This has the biggest impact on performance in the script.
## Have this high enough that it is precise, but low enough that it doesn't affect performance
@export var ray_count: int = 100
## The maximum length of the rays. Basically how far the character can see
@export var max_distance: float = 500.

@export_group("Collisions")
## What collision layers will block the vision. Have it set to the same layer as your walls, while avoiding things like items or characters
@export_flags_2d_physics var collision_layer_mask: int = 0
## Optional collision shape that the cone will be copied to.
## Use this if you want to have logic on things entering the cone (you probably do, unless you're just visualizing the cone without acting on it)
@export var write_collision_polygon: CollisionPolygon2D

@export_group("Visualization")
## Optional shape used to render the cone. This can then be textured and colored to customize the visual aspect
## or it can be null if you don't need to visualize the cone, but maybe just use it for AI
@export var write_polygon2d: Polygon2D
## Will draw lines for each ray. Only used for debugging, you should probably disable it in the actual project
@export var debug_lines: bool = false
## Will draw the shape outline of the cone. Only used for debugging, you should probably disable it in the actual project
@export var debug_shape: bool = false

@export_group("Optimizations")
## Introduce a minimum time (in msec) before recalculating. Useful to improve performance for slow moving objects,
## or objects where precise updates on every physics update are not necessary
@export var minimum_recalculate_time_msec: int = 0
## Should the vision cone be recalculated when the object hasn't moved?
## Set this to false to optimize by not recalculating the area if the object hasn't moved.
## May incorrectly avoid an update if the object rotates in place or the scene layout changes at runtime
@export var recalculate_if_static: bool = true
## How far the character has to move before the vision cone is recalculated. Only used if recalculate_if_static is false
@export var static_threshold: float = 2
## How far two adjacent ray points have to be from each other before adding a new point to the shape.
## Use this to reduce the number of vertices in the cone mesh when there are a lot of them close together.
## Increasing this can help with performance or when getting Godot errors like [Convex decomposing failed], at the cost of detail
## A <= 0 value will disable this behavior altogether. The value has to be squared, aka distance^2 (for performance reasons the sqrt is avoided)
@export var min_distance_sqr: float = 16

var _vision_points: Array[Vector2]
var _last_position = null  ## Optional[Vector2]
var _last_redraw_time: int = 0

# constants for optimization
@onready var _angle: float = deg_to_rad(angle_deg)
@onready var _angle_half: float = _angle/2.
@onready var _angular_delta: float = _angle / ray_count

func _process(_delta: float) -> void:
	if debug_lines or debug_shape:
		queue_redraw()

func _physics_process(delta: float) -> void:
	if Time.get_ticks_msec() - _last_redraw_time > minimum_recalculate_time_msec:
		_last_redraw_time = Time.get_ticks_msec()
		recalculate_vision()

func recalculate_vision(override_static_flag = false):
	var should_recalculate = override_static_flag or recalculate_if_static
	if not should_recalculate:
		var has_position_changed = _last_position == null or (global_position - _last_position).length() > static_threshold
		if not has_position_changed:
			return
	
	_last_position = global_position
	_vision_points.clear()
	_vision_points = calculate_vision_shape(override_static_flag)
	_update_collision_polygon()
	_update_render_polygon()

func calculate_vision_shape(override_static_flag = false) -> Array[Vector2]:
	var new_vision_points: Array[Vector2] = []
	var last_point = null # Optional[Vector2]

	if _angle < 2*PI:
		new_vision_points.append(Vector2.ZERO)
		last_point = Vector2.ZERO

	for i in range(ray_count + 1): 
		# TODO following transform should be customizable
		var new_point = _ray_to(Vector2(0, max_distance).rotated(_angular_delta * i + global_rotation - _angle_half))
		if min_distance_sqr > 0 and last_point:
			# check against min_distance_sqr
			var dist = (new_point - last_point).length_squared()
			if dist < min_distance_sqr:
				continue
		new_vision_points.append(new_point)
		last_point = new_point

	if _angle < 2*PI:
		new_vision_points.append(Vector2.ZERO)
	return new_vision_points

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
			draw_line(Vector2.ZERO, to, Color(0, 0, 1, 0.5))
		from = to
	
func _update_collision_polygon():
	if write_collision_polygon == null:
		return
	write_collision_polygon.polygon = _vision_points

func _update_render_polygon():
	if write_polygon2d == null:
		return
	write_polygon2d.polygon = _vision_points

func _ray_to(direction: Vector2) -> Vector2:
	# TODO add offset to origin
	var destination = global_position + direction
	var query = PhysicsRayQueryParameters2D.create(global_position, destination, collision_layer_mask)
	var collision = get_world_2d().direct_space_state.intersect_ray(query)

	var ray_position = collision.get("position", destination)
	return to_local(ray_position)
