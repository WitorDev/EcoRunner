class_name ObjectiveStation
extends Node2D

var is_on : bool = false
var is_in_range : bool = false
var player

@export var objective_station_quest : ObjectiveStationQuest

@onready var area2d : Area2D = $Area2D
@onready var sprite_node : Sprite2D = $Sprite2D


func _ready():
	# node setup
	if objective_station_quest == null:
		push_error("ObjectiveStationQuest not assigned!")
		return

	sprite_node.texture = objective_station_quest.sprite
	sprite_node.frame = 0

	area2d.body_shape_entered.connect(_on_area_2d_body_shape_entered)
	area2d.body_shape_exited.connect(_on_area_2d_body_shape_exited)

	player = get_tree().get_first_node_in_group("player")


func _process(_delta: float) -> void:
	if player == null:
		return

	if player.item_slot.item == null:
		return

	if is_in_range \
	and Input.is_action_just_pressed("interact") \
	and player.item_slot.item.name == objective_station_quest.objective_item_name \
	and is_on == false:

		print(objective_station_quest.objective_item_name + " Station turned on!")

		is_on = true
		sprite_node.frame = 1

		player.item_slot.remove_item()
		player.quest_manager.complete_quest(
			objective_station_quest.objective_quest_name
		)

		modulate = Color(1, 1, 1)


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		if !is_on \
		and player.item_slot.item != null \
		and player.item_slot.item.name == objective_station_quest.objective_item_name:
			modulate = Color(1, 1.2, 1.2)

		is_in_range = true


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		modulate = Color(1, 1, 1)
		is_in_range = false
