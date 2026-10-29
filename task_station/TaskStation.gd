extends Node2D
class_name TaskStation

@export var task_name: String = "Coletar resíduos"
@export var task_description: String = "Resgate os resíduos e entregue na estação correta."

@onready var sprite: Sprite2D = $Sprite2D


func interact(player: Player) -> void:
	if player == null:
		return

	if player.has_method("add_task") and not player.has_task(task_name):
		player.add_task(Task.new(task_name, task_description))

	if player.has_method("finish_task"):
		player.finish_task(task_name)
