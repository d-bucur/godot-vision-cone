extends CharacterBody2D

@export var speed = 1.
@export var distance = 300.

@onready var pos_start = position.x

func _physics_process(delta: float) -> void:
	var target_pos = pos_start + sin(Time.get_ticks_msec()/1000. * speed) * distance
	velocity = Vector2(target_pos - position.x, 0)
	move_and_slide()
