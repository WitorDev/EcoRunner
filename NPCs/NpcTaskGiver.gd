extends CharacterBody2D

@export var task_name: String = "Falar com o NPC"
@export var task_description: String = "Vá até o NPC e aceite a missão."
@export var interaction_radius: float = 30.0
@export var can_repeat_task: bool = false
@export var sprite_sheet: Texture2D
@export var sprite_columns: int = 3
@export var sprite_rows: int = 1
@export var frame_size: Vector2i = Vector2i(32, 32)
@export var animation_speed: float = 5.0

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interaction_area: Area2D = _get_interaction_area()
@onready var interaction_shape: CollisionShape2D = _get_interaction_shape()

var nearby_player: Player = null


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


func _ready() -> void:
	_setup_visuals()
	if interaction_shape != null and interaction_shape.shape is CircleShape2D:
		interaction_shape.shape.radius = interaction_radius

	if interaction_area != null:
		if not interaction_area.body_entered.is_connected(_on_body_entered):
			interaction_area.body_entered.connect(_on_body_entered)
		if not interaction_area.body_exited.is_connected(_on_body_exited):
			interaction_area.body_exited.connect(_on_body_exited)
	else:
		print("[NPC] Area2D de interação não encontrada. Verifique o nó 'InteractionArea' ou 'Area2D'.")


func _setup_visuals() -> void:
	if animated_sprite == null:
		animated_sprite = AnimatedSprite2D.new()
		animated_sprite.name = "AnimatedSprite2D"
		add_child(animated_sprite)
		animated_sprite.owner = self

	if sprite_sheet != null:
		animated_sprite.sprite_frames = _build_sprite_frames_from_sheet(sprite_sheet)
		animated_sprite.play("idle")
		animated_sprite.animation = "idle"
		animated_sprite.offset = Vector2.ZERO
		animated_sprite.position = Vector2.ZERO
		animated_sprite.z_index = 1

	if animated_sprite.sprite_frames == null or animated_sprite.sprite_frames.get_animation_names().is_empty():
		var fallback := Sprite2D.new()
		fallback.name = "FallbackSprite"
		if has_node("FallbackSprite"):
			fallback = get_node("FallbackSprite") as Sprite2D
		else:
			add_child(fallback)
			fallback.owner = self
		if sprite_sheet != null:
			fallback.texture = sprite_sheet


func _build_sprite_frames_from_sheet(sheet: Texture2D) -> SpriteFrames:
	var frames := SpriteFrames.new()
	if sheet == null:
		return frames

	var columns: int = int(max(sprite_columns, 1))
	var rows: int = int(max(sprite_rows, 1))
	var tile_width: int = int(max(frame_size.x, 1))
	var tile_height: int = int(max(frame_size.y, 1))
	var atlas_frames: Array[AtlasTexture] = []

	for row: int in range(rows):
		for column: int in range(columns):
			var x: int = column * tile_width
			var y: int = row * tile_height
			if x + tile_width > sheet.get_width() or y + tile_height > sheet.get_height():
				continue
			var atlas: AtlasTexture = AtlasTexture.new()
			atlas.atlas = sheet
			atlas.region = Rect2(x, y, tile_width, tile_height)
			atlas_frames.append(atlas)

	if atlas_frames.is_empty():
		return frames

	frames.add_animation("idle")
	for frame in atlas_frames:
		frames.add_frame("idle", frame)
	frames.set_animation_loop("idle", true)
	frames.set_animation_speed("idle", animation_speed)
	return frames


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


func give_task_to_player(player: Player) -> bool:
	if player == null:
		print("[NPC] tentativa de entregar tarefa sem player válido.")
		return false
	if task_name.strip_edges() == "":
		print("[NPC] tarefa vazia, não foi entregue.")
		return false
	if player.has_method("has_task") and player.has_task(task_name) and not can_repeat_task:
		print("[NPC] tarefa '%s' já existe para o jogador e não pode repetir." % task_name)
		return false
	if player.has_method("add_new_task"):
		print("[NPC] entregando tarefa '%s' para o player." % task_name)
		player.add_new_task(task_name, task_description)
		return true
	if player.has_method("add_task"):
		print("[NPC] entregando tarefa '%s' via add_task()." % task_name)
		player.add_task(Task.new(task_name, task_description))
		return true
	print("[NPC] player não possui add_new_task nem add_task().")
	return false


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact"):
		print("[NPC] ação interact pressionada. nearby_player=%s" % nearby_player)
		if nearby_player != null:
			give_task_to_player(nearby_player)
