extends Control

# Variável para ligar o inventário do Player
@export var inventory: InventoryComponent

# O %SlotIcon (Unique Name) ou o caminho direto evitam falhas de referência
@onready var slot_icon: TextureRect = %SlotIcon

@export_range(0.0, 1.0) var disabled_opacity: float = 0.3
@export_range(0.0, 1.0) var active_opacity: float = 1.0

func _ready() -> void:
	if inventory:
		inventory.item_changed.connect(_update_slot_ui)
		_update_slot_ui(inventory.current_item)
	else:
		_update_slot_ui(null)

func _update_slot_ui(item: ItemData) -> void:
	# Proteção: Se o nó slot_icon ainda não foi carregado pela engine, aguarda/ignora
	if not is_node_ready() or slot_icon == null:
		await ready
		if slot_icon == null:
			return

	if item != null and item.icon != null:
		slot_icon.texture = item.icon
		slot_icon.modulate.a = active_opacity
	else:
		slot_icon.texture = null
		slot_icon.modulate.a = disabled_opacity
