extends CharacterBody2D
class_name Player

signal tasks_changed

@export var speed: float = 200.0
@export var acceleration: float = 1800.0
@export var friction: float = 2200.0
@export var jump_velocity: float = -430.0
@export var gravity: float = 980.0
@export var max_fall_speed: float = 720.0
@export var coyote_time: float = 0.12
@export var jump_buffer_time: float = 0.12
@export var jump_cutoff: float = 0.25

@onready var inventory: InventoryComponent = $InventoryComponent
@onready var interaction_area: Area2D = $InteractionArea
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

var nearby_pickupables: Array[Pickupable] = []
var tasks: Array[Task] = []
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var speech_label: Label
var speech_timer: float = 0.0

func _ready() -> void:
	add_to_group("player")
	_setup_speech_label()
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)


func _setup_speech_label() -> void:
	speech_label = Label.new()
	speech_label.name = "SpeechLabel"
	speech_label.visible = false
	speech_label.position = Vector2(-60, -56)
	speech_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	speech_label.modulate = Color(1.0, 0.95, 0.7, 1.0)
	speech_label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var speech_settings := LabelSettings.new()
	speech_settings.font_size = 8
	speech_settings.font_color = speech_label.modulate
	speech_label.label_settings = speech_settings
	add_child(speech_label)


func show_speech_message(message: String, duration: float = 1.5) -> void:
	if speech_label == null:
		return
	if message.strip_edges() == "":
		return
	speech_label.text = message
	speech_label.visible = true
	speech_timer = max(0.0, duration)


func _process(delta: float) -> void:
	if speech_timer > 0.0:
		speech_timer -= delta
		if speech_timer <= 0.0 and speech_label != null:
			speech_label.visible = false


func add_task(task_data: Task) -> Task:
	if task_data == null:
		return null

	var existing_task := get_task(task_data.task_name)
	if existing_task != null:
		if not existing_task.is_done and task_data.is_done:
			existing_task.is_done = true
		_refresh_global_task_progress()
		tasks_changed.emit()
		return existing_task

	tasks.append(task_data)
	_refresh_global_task_progress()
	tasks_changed.emit()
	return task_data


func add_new_task(task_name_or_resource, description: String = "", required_item_id: String = "", required_quantity: int = 1) -> Task:
	var resolved_task: Task

	if task_name_or_resource is Task:
		resolved_task = task_name_or_resource
	else:
		var task_name_value: String = String(task_name_or_resource)
		if task_name_value.strip_edges() == "":
			push_warning("Task name cannot be empty.")
			return null
		if has_task(task_name_value):
			return get_task(task_name_value)
		resolved_task = Task.create(task_name_value, description, false, required_item_id, required_quantity)

	if has_task(resolved_task.task_name):
		return get_task(resolved_task.task_name)

	var added_task := add_task(resolved_task)
	if added_task != null:
		var task_added_signal: Signal = Signal(self, "tasks_changed")
		if task_added_signal != null:
			pass
	return added_task


func give_task_from_character(character: Node, task_name: String, description: String = "") -> bool:
	if character == null:
		return false
	if task_name.strip_edges() == "":
		return false
	if has_task(task_name):
		return false

	add_new_task(task_name, description)
	return true


func get_task(task_name_to_find: String) -> Task:
	for task in tasks:
		if task != null and task.task_name == task_name_to_find:
			return task
	return null


func get_tasks_by_required_item_id(item_id: String) -> Array[Task]:
	var matching_tasks: Array[Task] = []
	if item_id.strip_edges() == "":
		return matching_tasks
	for task in tasks:
		if task != null and task.required_item_id == item_id and not task.is_done:
			matching_tasks.append(task)
	return matching_tasks


func get_task_by_required_item_id(item_id: String) -> Task:
	if item_id.strip_edges() == "":
		return null
	for task in tasks:
		if task != null and task.required_item_id == item_id:
			return task
	return null


func complete_task_for_item_id(item_id: String) -> bool:
	if item_id.strip_edges() == "":
		return false
	if inventory == null:
		return false

	var matching_tasks := get_tasks_by_required_item_id(item_id)
	if matching_tasks.is_empty():
		return false

	var completed_any: bool = false
	for task in matching_tasks:
		if task == null or task.is_done:
			continue
		if not inventory.has_item(task.required_item_id, task.required_quantity):
			continue
		if not inventory.remove_item(task.required_item_id, task.required_quantity):
			continue
		task.is_done = true
		completed_any = true

	if completed_any:
		_refresh_global_task_progress()
		tasks_changed.emit()
		return true
	return false


func has_task(task_name_to_find: String) -> bool:
	return get_task(task_name_to_find) != null


func finish_task(task_name_to_finish: String) -> bool:
	var task := get_task(task_name_to_finish)
	if task == null:
		return false

	task.is_done = true
	_refresh_global_task_progress()
	tasks_changed.emit()
	return true


func try_complete_task_from_inventory(task_name_to_finish: String) -> bool:
	var task := get_task(task_name_to_finish)
	if task == null or task.is_done:
		return false
	if task.required_item_id == "":
		return false
	if inventory == null:
		return false
	if not inventory.has_item(task.required_item_id, task.required_quantity):
		return false
	if not inventory.remove_item(task.required_item_id, task.required_quantity):
		return false

	task.is_done = true
	_refresh_global_task_progress()
	tasks_changed.emit()
	return true


func _refresh_global_task_progress() -> void:
	if not is_inside_tree():
		return
	if Global == null:
		return
	Global.total_tasks = max(5, tasks.size())
	var completed_count: int = 0
	for task in tasks:
		if task != null and task.is_done:
			completed_count += 1
	Global.completed_tasks = completed_count
	Global.tasks_progress_changed.emit(Global.completed_tasks, Global.total_tasks)


func get_completed_task_count() -> int:
	var count: int = 0
	for task in tasks:
		if task != null and task.is_done:
			count += 1
	return count


func get_active_tasks() -> Array[Task]:
	var active_tasks: Array[Task] = []
	for task in tasks:
		if task != null and not task.is_done:
			active_tasks.append(task)
	return active_tasks


func _physics_process(delta: float) -> void:
	var move_input := Input.get_axis("left", "right")
	var is_jump_pressed := Input.is_action_pressed("pular")

	if is_on_floor():
		coyote_timer = coyote_time
	else:
		coyote_timer = max(coyote_timer - delta, 0.0)

	if Input.is_action_just_pressed("pular"):
		jump_buffer_timer = jump_buffer_time
	else:
		jump_buffer_timer = max(jump_buffer_timer - delta, 0.0)

	if jump_buffer_timer > 0.0 and coyote_timer > 0.0:
		velocity.y = jump_velocity
		jump_buffer_timer = 0.0
		coyote_timer = 0.0

	if not is_on_floor():
		var gravity_scale := 1.0
		if velocity.y > 0.0 and not is_jump_pressed:
			gravity_scale = 1.35
		elif velocity.y < 0.0 and is_jump_pressed:
			gravity_scale = 0.55
		velocity.y += gravity * gravity_scale * delta
		if velocity.y > max_fall_speed:
			velocity.y = max_fall_speed
	
	if move_input != 0.0:
		velocity.x = move_toward(velocity.x, move_input * speed, acceleration * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	move_and_slide()

	if Input.is_action_just_pressed("interact"):
		print("[Player] ação interact pressionada. itens_perto=%s" % nearby_pickupables.size())
		_try_pickup()

	_update_animation(move_input)


func _update_animation(direction: float) -> void:
	var facing_direction := direction
	if abs(velocity.x) > 1.0:
		facing_direction = sign(velocity.x)
	elif abs(direction) > 0.0:
		facing_direction = sign(direction)

	if facing_direction != 0:
		animated_sprite.flip_h = facing_direction < 0

	if not is_on_floor():
		animated_sprite.play("jump")
	elif facing_direction != 0:
		animated_sprite.play("walk")
	else:
		animated_sprite.play("idle")


func _on_interaction_area_entered(area: Area2D) -> void:
	if area is Pickupable:
		nearby_pickupables.append(area)


func _on_interaction_area_exited(area: Area2D) -> void:
	if area is Pickupable:
		nearby_pickupables.erase(area)


func _try_pickup() -> void:
	if nearby_pickupables.is_empty():
		print("[Player] tentou pegar item, mas não há itens próximos.")
		return

	var item := nearby_pickupables[0]
	print("[Player] tentando pegar item: %s" % item.name)
	item.interact(self)
	nearby_pickupables.erase(item)
