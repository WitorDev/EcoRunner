extends Node2D

var is_on : bool = false
var is_in_range : bool = false
var player
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	player = get_tree().get_first_node_in_group("player")
	
	if player == null:
		return
		
	if player.item_slot.item == null:
		return
		
	if is_in_range and Input.is_action_just_pressed("interact") and player.item_slot.item.name == "Battery" and is_on == false:
		print("Battery Station turned on!")
		is_on = true
		get_child(0).frame = 1
		player.item_slot.remove_item()
		player.quest_manager.complete_quest("Ligue o Painel Solar")
		modulate = Color(1, 1, 1) 

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		if !is_on and player.item_slot.item != null and player.item_slot.item.name == "Battery":
			modulate = Color(1, 1.2, 1.2)
		is_in_range = true


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		modulate = Color(1, 1, 1) 
		is_in_range = false
