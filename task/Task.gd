extends Resource
class_name Task

@export var task_name: String = "task"
@export_multiline var description: String = "task description"
@export var is_done: bool = false
@export var required_item_id: String = ""
@export var required_quantity: int = 1


func _init(
	p_task_name: String = "task",
	p_description: String = "task description",
	p_is_done: bool = false,
	p_required_item_id: String = "",
	p_required_quantity: int = 1
) -> void:
	task_name = p_task_name
	description = p_description
	is_done = p_is_done
	required_item_id = p_required_item_id
	required_quantity = max(1, p_required_quantity)


static func create(
	p_task_name: String = "task",
	p_description: String = "task description",
	p_is_done: bool = false,
	p_required_item_id: String = "",
	p_required_quantity: int = 1
) -> Task:
	var task := Task.new()
	task.task_name = p_task_name
	task.description = p_description
	task.is_done = p_is_done
	task.required_item_id = p_required_item_id
	task.required_quantity = max(1, p_required_quantity)
	return task


func clone() -> Task:
	var copied_task := Task.create(task_name, description, is_done, required_item_id, required_quantity)
	return copied_task
