extends CharacterBody2D
class_name Player

@export var speed: float = 200.0

@onready var inventory: Node = $InventoryComponent
@onready var interaction_area: Area2D = $InteractionArea

var nearby_pickupables: Array[Pickupable] = []


func _ready() -> void:
	add_to_group("player")
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)


func _physics_process(_delta: float) -> void:
	var direction := _get_input_direction()
	velocity = direction * speed
	move_and_slide()

	if Input.is_action_just_pressed("interagir"):
		_try_pickup()


func _get_input_direction() -> Vector2:
	var input_vector := Vector2.ZERO
	input_vector.x = Input.get_axis("ui_left", "ui_right")
	input_vector.y = Input.get_axis("ui_up", "ui_down")
	return input_vector.normalized()


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
