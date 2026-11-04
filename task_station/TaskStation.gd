extends Node2D
class_name TaskStation

@export var required_item_id: String = ""
@export var interaction_radius: float = 40.0

@onready var sprite: Sprite2D = $Sprite2D


func interact(player: Player) -> void:
	if player == null:
		return
	if required_item_id.strip_edges() == "":
		if player.has_method("show_speech_message"):
			player.show_speech_message("Essa estação não tem tarefa.")
		return
	if player.has_method("complete_task_for_item_id"):
		if player.complete_task_for_item_id(required_item_id):
			print("[TaskStation] tarefa concluída pelo item: %s" % required_item_id)
			return
	if player.has_method("show_speech_message"):
		player.show_speech_message("Ainda não tenho uma tarefa para isso.")
