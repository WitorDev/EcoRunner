extends AnimatableBody2D

var active : bool = false

@export var offset : Vector2 = Vector2(0, -200)
@export var speed : float = 25.0

var initial_position : Vector2
var target_position : Vector2

func _ready() -> void:
	initial_position = global_position
	target_position = initial_position + offset

func _physics_process(delta: float) -> void:
	var target = target_position if active else initial_position
	global_position = global_position.move_toward(target, speed * delta)

func activate() -> void:
	active = !active
