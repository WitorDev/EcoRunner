extends Node2D

@export var bullet_scene: PackedScene
@onready var target_origin = $ShootingOrigin

var timer: Timer

func _ready() -> void:
	timer = Timer.new()
	timer.wait_time = 2.0
	timer.autostart = true
	timer.one_shot = false
	add_child(timer)
	
	timer.timeout.connect(_spawn_bullet)

func _spawn_bullet() -> void:
	if bullet_scene == null:
		return
	
	var bullet = bullet_scene.instantiate()
	bullet.global_position = target_origin.position
	add_child(bullet)
