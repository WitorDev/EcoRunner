extends Node2D
class_name TaskStation

@export var task_name: String = "Coletar resíduos"
@export var task_description: String = "Resgate os resíduos e entregue na estação correta."

@onready var sprite: Sprite2D = $Sprite2D


func give_task_to_player(player: Player, task_name_to_give: String = task_name, description_to_give: String = task_description) -> bool:
	if player == null:
		return false
	if task_name_to_give.strip_edges() == "":
		return false
	if player.has_method("add_new_task"):
		if player.has_task(task_name_to_give):
			return false
		player.add_new_task(task_name_to_give, description_to_give)
		return true
	if player.has_method("add_task") and not player.has_task(task_name_to_give):
		player.add_task(Task.new(task_name_to_give, description_to_give))
		return true
	return false


func interact(player: Player) -> void:
	if player == null:
		return

	if player.has_task(task_name):
		var task := player.get_task(task_name)
		if task != null and not task.is_done and task.required_item_id != "":
			if player.try_complete_task_from_inventory(task.task_name):
				print("[TaskStation] tarefa concluída: %s" % task.task_name)
			return

	give_task_to_player(player)
