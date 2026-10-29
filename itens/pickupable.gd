extends Area2D
class_name Pickupable

@export var item_data: ItemData
@export var destroy_on_pickup: bool = true
@export var gravity_strength: float = 180.0
@export var hover_amplitude: float = 2.5
@export var hover_speed: float = 1.2
@export var hover_offset: Vector2 = Vector2.ZERO

@onready var prompt_label: Label = $PromptLabel
@onready var sprite: Sprite2D = $Sprite2D

var base_position: Vector2
var vertical_velocity: float = 0.0
var pickup_animation_started: bool = false

signal picked_up(item_data: Resource)


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	prompt_label.visible = false
	base_position = global_position
	_update_sprite()


func _process(delta: float) -> void:
	if pickup_animation_started:
		return

	var hover_y := sin(Time.get_ticks_msec() * 0.01 * hover_speed) * hover_amplitude
	if sprite:
		sprite.position = hover_offset + Vector2(0, hover_y)

	vertical_velocity += gravity_strength * delta
	global_position.y += vertical_velocity * delta

	if global_position.y >= base_position.y:
		global_position.y = base_position.y
		vertical_velocity = 0.0


func _update_sprite() -> void:
	if item_data and item_data.icon:
		sprite.texture = item_data.icon
	else:
		push_warning("Pickupable sem ícone definido em item_data: %s" % name)


func _on_area_entered(area: Area2D) -> void:
	var body := area.get_parent()
	if body and body.is_in_group("player"):
		prompt_label.visible = true


func _on_area_exited(area: Area2D) -> void:
	var body := area.get_parent()
	if body and body.is_in_group("player"):
		prompt_label.visible = false


func interact(body: Node2D) -> void:
	if item_data == null:
		push_warning("Pickupable sem item_data definido em: %s" % name)
		return

	var inventory := body.get_node_or_null("InventoryComponent")

	if inventory and inventory.has_method("add_item"):
		var added: bool = inventory.add_item(item_data)
		if not added:
			return

	picked_up.emit(item_data)

	if destroy_on_pickup:
		_start_pickup_effect()
		return

	queue_free()


func _start_pickup_effect() -> void:
	if pickup_animation_started:
		return

	pickup_animation_started = true
	prompt_label.visible = false

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "position", sprite.position + Vector2(0, -20), 0.18)
	tween.tween_property(sprite, "scale", sprite.scale * 1.35, 0.18)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.18)
	tween.finished.connect(_on_pickup_finished)


func _on_pickup_finished() -> void:
	queue_free()
