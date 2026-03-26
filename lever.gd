extends Node2D

var is_in_range : bool = false
var active : bool = false

@export var activatable_node : Node
@export var sync_to_lever : Node2D

const REQUIRED_QUEST = "Ligue a plataforma de transporte"

func _ready():
	update_visual()

func _process(delta: float) -> void:
	if is_in_range:
		modulate = Color(1, 1.5, 1.5)
	else:
		modulate = Color(1, 1, 1)

	if is_in_range and Input.is_action_just_pressed("interact"):
		activate()

func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		is_in_range = true

func _on_area_2d_body_shape_exited(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.is_in_group("player"):
		is_in_range = false

func is_powered() -> bool:
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return false
	
	if player.quest_manager == null:
		return false
	
	for quest in player.quest_manager.quests:
		if quest.title == REQUIRED_QUEST and quest.completed:
			return true
	
	return false

func activate():
	if not is_powered():
		print("lever unpowered")
		return
	
	active = !active
	update_visual()
	
	if sync_to_lever != null:
		sync_to_lever.set_state(active)
	
	if activatable_node != null:
		activatable_node.activate()

func set_state(state: bool):
	active = state
	update_visual()

func update_visual():
	$Sprite2D.frame = 1 if active else 0
