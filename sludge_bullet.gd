extends Area2D

@export var speed: float = 100.0

func _ready() -> void:
	$AnimationPlayer.play("new_animation")

func _physics_process(delta: float) -> void:
	position.x += speed * delta

func _on_body_entered(body: Node2D) -> void:
	if(body.is_in_group("player")):
		body.take_damage(1)
	queue_free()	
