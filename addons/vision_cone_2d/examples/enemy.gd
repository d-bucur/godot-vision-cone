extends CharacterBody2D

@export var vision_renderer: Polygon2D
@export var alert_color: Color
@export var is_rotating = false
@export var rotation_speed = 0.1
@export var rotation_angle = 90

@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE
@onready var rot_start = rotation

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	# print("%s is seeing %s" % [self, body])
	vision_renderer.color = alert_color

func _on_vision_cone_area_body_exited(body: Node2D) -> void:
	# print("%s stopped seeing %s" % [self, body])
	vision_renderer.color = original_color

func _physics_process(delta: float) -> void:
	if is_rotating:
		rotation = rot_start + sin(Time.get_ticks_msec()/1000. * rotation_speed) * deg_to_rad(rotation_angle/2.)
