extends CanvasLayer
class_name Mochila

@onready var slot_icon: TextureRect = $SlotBackground/SlotIcon

var inventory: InventoryComponent


func _ready() -> void:
	call_deferred("_connect_to_player")


func _connect_to_player() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		push_warning("Mochila: nenhum nó no grupo 'player' encontrado.")
		return

	inventory = player.get_node_or_null("InventoryComponent")
	if inventory == null:
		push_warning("Mochila: InventoryComponent não encontrado no Player.")
		return

	inventory.inventory_changed.connect(_update_display)
	_update_display()


func _update_display() -> void:
	var item := inventory.get_current_item()
	if item and item.icon:
		slot_icon.texture = item.icon
		slot_icon.visible = true
	else:
		slot_icon.texture = null
		slot_icon.visible = false
