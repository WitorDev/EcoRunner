extends Control

# Variável para ligar o inventário do Player
@export var inventory: InventoryComponent

@onready var slot_icon: TextureRect = get_node_or_null("%SlotIcon")
@onready var canvas: CanvasLayer = get_node_or_null("CanvasLayer")

@export_range(0.0, 1.0) var disabled_opacity: float = 0.3
@export_range(0.0, 1.0) var active_opacity: float = 1.0

var task_list: VBoxContainer
var player: Player


func _ready() -> void:
	_setup_task_list()
	_bind_player()
	_update_slot_ui(null)


func _bind_player() -> void:
	var player_node := get_tree().get_first_node_in_group("player") as Node
	if player_node == null:
		return

	player = player_node as Player
	if player != null:
		if player.has_signal("tasks_changed"):
			player.tasks_changed.connect(_refresh_task_ui)
		if player.has_node("InventoryComponent"):
			inventory = player.get_node("InventoryComponent") as InventoryComponent
			if inventory != null and inventory.has_signal("item_changed"):
				inventory.item_changed.connect(_update_slot_ui)
			_update_slot_ui(inventory.current_item if inventory != null else null)
		_refresh_task_ui()


func _setup_task_list() -> void:
	if task_list != null and is_instance_valid(task_list):
		return

	task_list = VBoxContainer.new()
	task_list.name = "TaskList"
	task_list.position = Vector2(20, 20)
	task_list.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	add_child(task_list)

	var title := Label.new()
	title.name = "TaskTitle"
	title.text = "MISSÕES"
	title.modulate = Color(1, 0.9, 0.3, 1)
	title.add_theme_font_size_override("font_size", 20)
	task_list.add_child(title)


func _refresh_task_ui() -> void:
	if task_list == null or not is_instance_valid(task_list):
		return

	for child in task_list.get_children():
		if child.name != "TaskTitle":
			child.queue_free()

	if player == null or player.tasks.is_empty():
		var empty_label := Label.new()
		empty_label.text = "Nenhuma missão ativa"
		task_list.add_child(empty_label)
		return

	for task in player.get_active_tasks():
		var label := Label.new()
		label.text = "• %s - %s" % [task.task_name, task.description]
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.custom_minimum_size = Vector2(260, 30)
		task_list.add_child(label)

	for completed_task in player.tasks:
		if completed_task == null or not completed_task.is_done:
			continue
		var done_label := Label.new()
		done_label.text = "✓ %s" % completed_task.task_name
		done_label.modulate = Color(0.5, 1.0, 0.5, 1.0)
		task_list.add_child(done_label)


func _update_slot_ui(item: ItemData) -> void:
	if slot_icon == null:
		return

	if item != null and item.icon != null:
		slot_icon.texture = item.icon
		slot_icon.modulate.a = active_opacity
	else:
		slot_icon.texture = null
		slot_icon.modulate.a = disabled_opacity
