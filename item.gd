extends Node2D

@export var item_resource : Item
var is_showing_ui : bool
var interact_button_ui_instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if item_resource and item_resource.sprite:
		$Sprite2D.texture = item_resource.sprite


func interact() -> void:
	print("interacted")
	var player = get_tree().get_first_node_in_group("player")
	
	if player:
		# Route the item data directly into the player's ItemSlot child node
		if player.item_slot and player.item_slot.has_method("add_item"):
			player.item_slot.add_item(item_resource)
			
			# Clean up the player's focus reference right before deleting this object
			if player.current_interactable == self:
				player.current_interactable = null
				
			queue_free()
		else:
			print("Error: Player node found, but it doesn't have a valid ItemSlot configured.")


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player") and !is_showing_ui:
		# Only take over interaction focus if the player isn't already targeting something
		if body.current_interactable == null:
			body.current_interactable = self
			
			modulate = Color(1, 2, 2) # extra blue glow
			is_showing_ui = true


func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == null:
		return

	if body.is_in_group("player") and is_showing_ui:
		# Only clear focus if the player is actually leaving THIS specific item scene instance
		if body.current_interactable == self:
			body.current_interactable = null
			
		is_showing_ui = false
		modulate = Color(1, 1, 1) # reset color back to normal
