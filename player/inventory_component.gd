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


func has_item(item_id: String, quantity: int = 1) -> bool:
	if item_id.strip_edges() == "":
		return false

	var total_quantity: int = 0
	for slot in items:
		var data: ItemData = slot.get("data") as ItemData
		if data != null and data.item_id == item_id:
			total_quantity += int(slot.get("quantity", 1))

	return total_quantity >= quantity


func remove_item(item_id: String, quantity: int = 1) -> bool:
	if item_id.strip_edges() == "":
		return false
	if not has_item(item_id, quantity):
		return false

	var remaining_to_remove: int = quantity
	for index in range(items.size() - 1, -1, -1):
		var slot: Dictionary = items[index]
		var data: ItemData = slot.get("data") as ItemData
		if data == null or data.item_id != item_id:
			continue

		var slot_quantity: int = int(slot.get("quantity", 1))
		var taken: int = min(slot_quantity, remaining_to_remove)
		var new_quantity: int = slot_quantity - taken
		if new_quantity <= 0:
			items.remove_at(index)
		else:
			slot["quantity"] = new_quantity
			items[index] = slot

		remaining_to_remove -= taken
		if remaining_to_remove <= 0:
			break

	_emit_inventory_changed()
	return true


func drop_current_item(drop_position: Vector2) -> bool:
	if items.is_empty():
		return false

	var slot: Dictionary = items[0]
	var item_data := slot.get("data") as ItemData
	if item_data == null:
		push_error("Não foi possível soltar o item: o primeiro espaço do inventário está inválido.")
		return false

	if not _spawn_pickup(item_data, drop_position):
		return false

	var quantity: int = int(slot.get("quantity", 1))
	if quantity > 1:
		slot["quantity"] = quantity - 1
		items[0] = slot
	else:
		items.remove_at(0)

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
	var old_item := old_slot.get("data") as ItemData
	if old_item == null:
		push_error("Não foi possível soltar o item antigo: o primeiro espaço do inventário está inválido.")
		items.push_front(old_slot)
		return

	var player := get_parent()
	var drop_position := Vector2.ZERO
	if player is Node2D and is_instance_valid(player):
		drop_position = player.global_position
	if not _spawn_pickup(old_item, drop_position):
		items.push_front(old_slot)
		return

	_emit_inventory_changed()


func _spawn_pickup(item_data: ItemData, spawn_position: Vector2) -> bool:
	var current_scene := get_tree().current_scene
	if current_scene == null:
		push_error("Não foi possível soltar o item: a cena atual não está disponível.")
		return false
	var scene_2d := current_scene as Node2D
	if scene_2d == null:
		push_error("Não foi possível soltar o item: a cena atual não suporta objetos 2D.")
		return false

	var pickup := PICKUPABLE_SCENE.instantiate() as Pickupable
	if pickup == null:
		push_error("Não foi possível criar o coletável para o item.")
		return false

	pickup.item_data = item_data
	pickup.position = scene_2d.to_local(spawn_position)
	current_scene.add_child(pickup)
	return true
