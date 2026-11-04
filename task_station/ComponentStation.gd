extends Node2D
class_name ComponentStation

@export var required_item_id: String = ""
@export var required_quantity: int = 1
@export var interaction_radius: float = 40.0
@export var sprite_sheet: Texture2D
@export var sprite_columns: int = 2
@export var sprite_rows: int = 1
@export var frame_size: Vector2i = Vector2i(64, 64)
@export var pending_frame_index: int = 0
@export var done_frame_index: int = 1

@onready var sprite: Sprite2D = $Sprite2D
@onready var interaction_area: Area2D = _get_interaction_area()
@onready var interaction_shape: CollisionShape2D = _get_interaction_shape()

var nearby_player: Player = null


func _ready() -> void:
	_setup_visuals()
	_apply_radius()
	_connect_interaction_area()
	_update_visual_state()


func _setup_visuals() -> void:
	if sprite == null:
		sprite = Sprite2D.new()
		sprite.name = "Sprite2D"
		add_child(sprite)
		sprite.owner = self

	if sprite_sheet != null:
		_set_sprite_frame_from_sheet(pending_frame_index)
		sprite.texture = sprite_sheet
		sprite.centered = true
		sprite.z_index = 1


func _set_sprite_frame_from_sheet(frame_index: int) -> void:
	if sprite_sheet == null:
		return
	if sprite == null:
		return

	var columns: int = int(max(sprite_columns, 1))
	var rows: int = int(max(sprite_rows, 1))
	var tile_width: int = int(max(frame_size.x, 1))
	var tile_height: int = int(max(frame_size.y, 1))
	var max_index: int = columns * rows
	var safe_index: int = clamp(frame_index, 0, max_index - 1)

	var column: int = safe_index % columns
	var row: int = safe_index / columns
	var x: int = column * tile_width
	var y: int = row * tile_height

	var region := Rect2(x, y, tile_width, tile_height)
	var atlas := AtlasTexture.new()
	atlas.atlas = sprite_sheet
	atlas.region = region
	sprite.texture = atlas
	sprite.offset = Vector2.ZERO


func _set_visual_state(is_done: bool) -> void:
	if sprite_sheet == null:
		return
	var target_frame: int = pending_frame_index
	if is_done:
		target_frame = done_frame_index
	_set_sprite_frame_from_sheet(target_frame)


func _get_interaction_area() -> Area2D:
	var area := get_node_or_null("InteractionArea") as Area2D
	if area == null:
		area = get_node_or_null("Area2D") as Area2D
	return area


func _get_interaction_shape() -> CollisionShape2D:
	if interaction_area == null:
		return null

	var shape := interaction_area.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if shape == null:
		shape = get_node_or_null("CollisionShape2D") as CollisionShape2D
	return shape


func _apply_radius() -> void:
	if interaction_shape == null:
		return
	if interaction_shape.shape is CircleShape2D:
		interaction_shape.shape.radius = interaction_radius


func _connect_interaction_area() -> void:
	if interaction_area == null:
		print("[ComponentStation] Area2D não encontrada. Adicione um nó 'InteractionArea' ou 'Area2D'.")
		return
	if not interaction_area.body_entered.is_connected(_on_body_entered):
		interaction_area.body_entered.connect(_on_body_entered)
	if not interaction_area.body_exited.is_connected(_on_body_exited):
		interaction_area.body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node) -> void:
	if body == null:
		return
	if body is Player:
		nearby_player = body


func _on_body_exited(body: Node) -> void:
	if body == null:
		return
	if body == nearby_player:
		nearby_player = null


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and nearby_player != null:
		try_complete_task(nearby_player)


func try_complete_task(player: Player) -> bool:
	if player == null:
		return false
	if required_item_id.strip_edges() == "":
		print("[ComponentStation] estação sem required_item_id configurado.")
		if player.has_method("show_speech_message"):
			player.show_speech_message("Essa estação não tem tarefa.")
		return false
	if player.has_method("get_tasks_by_required_item_id"):
		var matching_tasks := player.get_tasks_by_required_item_id(required_item_id)
		if matching_tasks.is_empty():
			print("[ComponentStation] nenhum item ativo para '%s' nesta estação." % required_item_id)
			if player.has_method("show_speech_message"):
				player.show_speech_message("Ainda não tenho uma tarefa para isso.")
			return false
	if player.has_method("complete_task_for_item_id"):
		var completed := player.complete_task_for_item_id(required_item_id)
		_update_visual_state(player)
		if completed:
			print("[ComponentStation] tarefa concluída pelo item: %s" % required_item_id)
		else:
			print("[ComponentStation] item '%s' está no inventário, mas não corresponde a uma tarefa ativa." % required_item_id)
			if player.has_method("show_speech_message"):
				player.show_speech_message("Esse item não está na minha missão.")
		return completed
	print("[ComponentStation] jogador não possui complete_task_for_item_id().")
	if player.has_method("show_speech_message"):
		player.show_speech_message("Não consigo usar isso agora.")
	return false


func _update_visual_state(player: Player = null) -> void:
	if sprite == null:
		return
	if player == null:
		player = nearby_player
	if player == null and get_tree() != null:
		player = get_tree().get_first_node_in_group("player") as Player
	var is_done := false
	if player != null and required_item_id.strip_edges() != "":
		if player.has_method("get_task_by_required_item_id"):
			var task: Task = player.get_task_by_required_item_id(required_item_id)
			is_done = task != null and task.is_done
		elif player.has_method("get_tasks_by_required_item_id"):
			var matching_tasks := player.get_tasks_by_required_item_id(required_item_id)
			if matching_tasks.is_empty():
				for task in player.tasks:
					if task != null and task.required_item_id == required_item_id:
						is_done = task.is_done
						break
	_set_visual_state(is_done)


func _is_done_for_current_player() -> bool:
	if required_item_id.strip_edges() == "":
		return false
	var player_to_check := nearby_player
	if player_to_check == null and get_tree() != null:
		player_to_check = get_tree().get_first_node_in_group("player") as Player
	if player_to_check == null:
		return false
	if player_to_check.has_method("get_task_by_required_item_id"):
		var task: Task = player_to_check.get_task_by_required_item_id(required_item_id)
		if task == null:
			return false
		return task.is_done
	return false
