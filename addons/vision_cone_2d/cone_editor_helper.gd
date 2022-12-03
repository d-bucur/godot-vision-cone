@tool
extends Node2D

@export var is_visible = true
@export var color = Color.RED

@onready var vision_cone: VisionCone2D = get_parent()

## Draws a preview of the vision cone inside the editor. The actual vision cone cannot be displayed as a lot of stuff
## is missing before the game is actually started
func _draw():
	if not is_visible or not Engine.is_editor_hint():
		return
	var rot_diff = global_rotation - vision_cone.global_rotation
	var half_angle = deg_to_rad(vision_cone.angle_deg)/2.
	var right = Vector2(0, vision_cone.max_distance).rotated(rot_diff + half_angle)
	var left = Vector2(0, vision_cone.max_distance).rotated(rot_diff - half_angle)
	draw_line(Vector2.ZERO, right, color)
	draw_line(Vector2.ZERO, left, color)
	draw_line(right, left, color)
