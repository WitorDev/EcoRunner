extends CharacterBody2D
class_name Player

@export var speed: float = 200.0
@export var jump_velocity: float = -400.0
@export var gravity: float = 980.0

@onready var inventory: Node = $InventoryComponent
@onready var interaction_area: Area2D = $InteractionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var nearby_pickupables: Array[Pickupable] = []


func _ready() -> void:
	add_to_group("player")
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)


func _physics_process(delta: float) -> void:
	# Gravidade: puxa o player pra baixo quando ele não está no chão.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Pulo: só permitido quando o player está tocando o chão.
	if Input.is_action_just_pressed("pular") and is_on_floor():
		velocity.y = jump_velocity

	# Movimento horizontal.
	var direction := Input.get_axis("ui_left", "ui_right")
	velocity.x = direction * speed

	move_and_slide()

	if Input.is_action_just_pressed("interagir"):
		_try_pickup()

	_update_animation(direction)


func _update_animation(direction: float) -> void:
	if not is_on_floor():
		animated_sprite.play("jump")
	elif direction != 0:
		animated_sprite.play("walk")
		animated_sprite.flip_h = direction < 0
	else:
		animated_sprite.play("idle")


func _on_interaction_area_entered(area: Area2D) -> void:
	if area is Pickupable:
		nearby_pickupables.append(area)


func _on_interaction_area_exited(area: Area2D) -> void:
	if area is Pickupable:
		nearby_pickupables.erase(area)


func _try_pickup() -> void:
	if nearby_pickupables.is_empty():
		return

	var item := nearby_pickupables[0]
	item.interact(self)
	nearby_pickupables.erase(item)
