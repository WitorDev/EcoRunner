extends Node
class_name InventoryComponent

@export var max_slots: int = 20

var items: Array[Dictionary] = []

signal inventory_changed
signal item_rejected(item_data: Resource)


func add_item(item_data: Resource, quantity: int = 1) -> bool:
	if item_data == null or quantity <= 0:
		return false

	if "stackable" in item_data and item_data.stackable:
		var slot := _find_stackable_slot(item_data)
		if slot != -1:
			var max_stack: int = item_data.max_stack if "max_stack" in item_data else 99
			var space_left: int = max_stack - items[slot]["quantity"]
			var to_add: int = min(space_left, quantity)

			items[slot]["quantity"] += to_add
			quantity -= to_add

			if quantity <= 0:
				inventory_changed.emit()
				return true

	if items.size() >= max_slots:
		item_rejected.emit(item_data)
		return false

	items.append({"data": item_data, "quantity": quantity})
	inventory_changed.emit()
	return true


func remove_item(item_data: Resource, quantity: int = 1) -> bool:
	var slot := _find_stackable_slot(item_data)
	if slot == -1:
		return false

	items[slot]["quantity"] -= quantity

	if items[slot]["quantity"] <= 0:
		items.remove_at(slot)

	inventory_changed.emit()
	return true


func has_item(item_data: Resource) -> bool:
	return _find_stackable_slot(item_data) != -1


func get_item_count(item_data: Resource) -> int:
	var slot := _find_stackable_slot(item_data)
	if slot == -1:
		return 0
	return items[slot]["quantity"]


func _find_stackable_slot(item_data: Resource) -> int:
	var target_id = item_data.item_id if "item_id" in item_data else item_data.resource_path

	for i in items.size():
		var slot_data = items[i]["data"]
		var slot_id = slot_data.item_id if "item_id" in slot_data else slot_data.resource_path
		if slot_id == target_id:
			return i

	return -1
