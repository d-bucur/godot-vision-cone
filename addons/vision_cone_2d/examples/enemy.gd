extends CharacterBody2D

@export var vision_renderer: Polygon2D
@export var alert_color: Color

@onready var original_color = vision_renderer.color if vision_renderer else Color.WHITE

func _on_vision_cone_area_body_entered(body: Node2D) -> void:
	print("%s is seeing %s" % [self, body])
	vision_renderer.color = alert_color

func _on_vision_cone_area_body_exited(body: Node2D) -> void:
	print("%s stopped seeing %s" % [self, body])
	vision_renderer.color = original_color
