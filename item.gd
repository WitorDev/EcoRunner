extends Node2D

@export var item_resource : Item
var is_showing_ui : bool
var interact_button_ui_instance

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Sprite2D.texture = item_resource.sprite

func _process(delta: float) -> void:
	if is_showing_ui and Input.is_action_just_pressed("interact"):
		interact()

func interact():
	print("interacted")
	var player = get_tree().get_first_node_in_group("player")
	player.add_item(item_resource)
	queue_free()


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
		if body.is_in_group("player") and !is_showing_ui and !body.interactable_in_range:
			# body.interactable_in_range = true
			modulate = Color(1, 2, 2) # extra blue glow

			is_showing_ui = true

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body == null:
		return

	if body.is_in_group("player") and is_showing_ui:
		# body.interactable_in_range = false
		is_showing_ui = false
		modulate = Color(1, 1, 1) # extra blue glow
