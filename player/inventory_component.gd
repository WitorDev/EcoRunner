extends Node
class_name InventoryComponent

## Cena usada pra soltar o item antigo de volta no mapa quando o slot já está ocupado.
const PICKUPABLE_SCENE: PackedScene = preload("res://itens/pickupable.tscn")

## Quantidade de slots (1 = mochila com um espaço só).
@export var max_slots: int = 1

## Cada slot: { "data": ItemData, "quantity": int }
var items: Array[Dictionary] = []
var current_item: ItemData = null

signal inventory_changed
signal item_changed(item: ItemData)


func add_item(item_data: Resource, quantity: int = 1) -> bool:
	if item_data == null or quantity <= 0:
		return false

	if items.size() >= max_slots:
		_drop_oldest_item()

	items.append({"data": item_data, "quantity": quantity})
	current_item = get_current_item()
	_emit_inventory_changed()
	return true


func get_current_item() -> ItemData:
	if items.is_empty():
		return null
	return items[0]["data"]


func _emit_inventory_changed() -> void:
	current_item = get_current_item()
	inventory_changed.emit()
	item_changed.emit(current_item)


func _drop_oldest_item() -> void:
	if items.is_empty():
		return

	var old_slot: Dictionary = items.pop_front()
	var old_item: Resource = old_slot["data"]

	var pickup := PICKUPABLE_SCENE.instantiate()
	pickup.item_data = old_item

	var player := get_parent()
	if player != null and is_instance_valid(player):
		get_tree().current_scene.add_child(pickup)
		pickup.global_position = player.global_position
	else:
		get_tree().current_scene.add_child(pickup)
		pickup.global_position = Vector2.ZERO

	_emit_inventory_changed()
