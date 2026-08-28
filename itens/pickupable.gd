extends Area2D
class_name Pickupable

@export var item_data: ItemData
@export var destroy_on_pickup: bool = true

@onready var prompt_label: Label = $PromptLabel
@onready var sprite: Sprite2D = $Sprite2D

signal picked_up(item_data: Resource)


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	prompt_label.visible = false
	_update_sprite()


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
		queue_free()
