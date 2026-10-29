extends RefCounted
class_name Task

var task_name: String = "task"
var description: String = "task description"
var is_done: bool = false


func _init(p_task_name: String = "task", p_description: String = "task description", p_is_done: bool = false) -> void:
	task_name = p_task_name
	description = p_description
	is_done = p_is_done
