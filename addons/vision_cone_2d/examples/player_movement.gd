extends CharacterBody2D

@export var speed = 1.
@export var distance = 300.

@onready var start_pos = position.x

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")


func _physics_process(delta: float) -> void:
	position.x = start_pos + sin(Time.get_ticks_msec()/1000. * speed) * distance
