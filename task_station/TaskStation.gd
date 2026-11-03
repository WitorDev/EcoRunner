extends Node
class_name TaskStation

@onready var task_station_resource : Texture2D
@onready var sprite

func interact(player : Player):
	player.finish_task()
