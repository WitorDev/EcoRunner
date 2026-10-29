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

func _ready() -> void:
	add_to_group("player")
	interaction_area.area_entered.connect(_on_interaction_area_entered)
	interaction_area.area_exited.connect(_on_interaction_area_exited)


func add_task(task_data: Task) -> Task:
	if task_data == null:
		return null

	var existing_task := get_task(task_data.task_name)
	if existing_task != null:
		if not existing_task.is_done and task_data.is_done:
			existing_task.is_done = true
		tasks_changed.emit()
		return existing_task

	tasks.append(task_data)
	tasks_changed.emit()
	return task_data


func get_task(task_name_to_find: String) -> Task:
	for task in tasks:
		if task != null and task.task_name == task_name_to_find:
			return task
	return null


func has_task(task_name_to_find: String) -> bool:
	return get_task(task_name_to_find) != null


func finish_task(task_name_to_finish: String) -> bool:
	var task := get_task(task_name_to_finish)
	if task == null:
		return false

	task.is_done = true
	tasks_changed.emit()
	return true


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

	if Input.is_action_just_pressed("interagir"):
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
		return

	var item := nearby_pickupables[0]
	item.interact(self)
	nearby_pickupables.erase(item)
