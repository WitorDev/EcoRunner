extends RefCounted
class_name Task

var task_name: String = "task"
var description: String = "task description"
var is_done: bool = false
var required_item_id: String = ""
var required_quantity: int = 1


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
