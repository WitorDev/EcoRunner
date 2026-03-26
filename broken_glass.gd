extends Node2D

@export var damage : int = 1
@export var damage_interval : float = 1

var player_inside : Node2D = null

func _ready():
	$Sprite2D/Area2D/Timer.wait_time = damage_interval

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = body
		
		# 🔥 Deal damage instantly
		player_inside.take_damage(damage)
		
		# Then start ticking damage
		$Sprite2D/Area2D/Timer.start()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body == player_inside:
		player_inside = null
		$Sprite2D/Area2D/Timer.stop()

func _on_timer_timeout() -> void:
	if player_inside:
		player_inside.take_damage(damage)
