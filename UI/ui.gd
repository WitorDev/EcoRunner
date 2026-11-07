extends Control

# Variável para ligar o inventário do Player
@export var inventory: InventoryComponent

@onready var slot_icon: TextureRect = get_node_or_null("%SlotIcon")
@onready var canvas: CanvasLayer = get_node_or_null("CanvasLayer")
@onready var health_display: RichTextLabel = get_node_or_null("CanvasLayer/HealthDisplay")

@export_range(0.0, 1.0) var disabled_opacity: float = 0.3
@export_range(0.0, 1.0) var active_opacity: float = 1.0

var task_panel: PanelContainer
var task_list: VBoxContainer
var player: Player
var task_notification: Label
var notification_timer: float = 0.0


func _ready() -> void:
	_setup_task_notification()
	_bind_player()
	_update_slot_ui(null)
	_find_task_panel()
	_set_task_panel_visible(false)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("tasks"):
		print("[UI] tecla de tarefas pressionada. task_panel_valid=%s" % (task_panel != null))
		_toggle_task_panel()
		print("[UI] painel de tarefas visível=%s" % (task_panel.visible if task_panel != null else false))


func _bind_player() -> void:
	var player_node := get_tree().get_first_node_in_group("player") as Node
	if player_node == null:
		return

	player = player_node as Player
	if player != null:
		if player.has_signal("health_changed"):
			player.health_changed.connect(_update_health_display)
		if player.has_method("take_damage"):
			_update_health_display(player.health, player.max_health)
		if player.has_signal("tasks_changed"):
			player.tasks_changed.connect(_on_tasks_changed)
		if player.has_node("InventoryComponent"):
			inventory = player.get_node("InventoryComponent") as InventoryComponent
			if inventory != null and inventory.has_signal("item_changed"):
				inventory.item_changed.connect(_update_slot_ui)
			_update_slot_ui(inventory.current_item if inventory != null else null)
		_refresh_task_ui()


func _update_health_display(current: int, maximum: int) -> void:
	if health_display == null:
		return
	health_display.text = "[color=#ef476f]" + "♥".repeat(current) \
		+ "[/color][color=#555555]" + "♥".repeat(maximum - current) + "[/color]"


func _on_tasks_changed() -> void:
	_refresh_task_ui()
	if player != null:
		var last_task: Task = player.get_active_tasks().back() if not player.get_active_tasks().is_empty() else null
		if last_task != null:
			_show_task_notification("Tarefa: %s adicionada ao quadro" % last_task.task_name)


func _find_task_panel() -> void:
	task_panel = get_node_or_null("CanvasLayer/TaskPanel") as PanelContainer
	if task_panel == null:
		return

	task_list = task_panel.get_node_or_null("TaskList") as VBoxContainer
	_refresh_task_ui()


func _setup_task_notification() -> void:
	task_notification = Label.new()
	task_notification.name = "TaskNotification"
	task_notification.visible = false
	task_notification.modulate = Color(1.0, 0.95, 0.4, 1.0)
	task_notification.add_theme_font_size_override("font_size", 18)
	task_notification.position = Vector2(20, 220)
	add_child(task_notification)


func _show_task_notification(message: String) -> void:
	if task_notification == null:
		return
	task_notification.text = message
	task_notification.visible = true
	notification_timer = 2.2


func _process(delta: float) -> void:
	if notification_timer > 0.0:
		notification_timer -= delta
		if notification_timer <= 0.0 and task_notification != null:
			task_notification.visible = false


func _toggle_task_panel() -> void:
	if task_panel == null or not is_instance_valid(task_panel):
		return
	_set_task_panel_visible(not task_panel.visible)


func _set_task_panel_visible(is_visible: bool) -> void:
	if task_panel == null or not is_instance_valid(task_panel):
		return
	task_panel.visible = is_visible
	_refresh_task_ui()


func _refresh_task_ui() -> void:
	if task_panel == null or not is_instance_valid(task_panel):
		return

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
