extends Node2D

const PAUSE_MENU_SCENE := preload("res://tela_inicial/menu/opcoes_menu.tscn")
const UI_SCENE := preload("res://UI/ui.tscn")

@onready var pause_layer: CanvasLayer = $PauseLayer

var pause_menu_instance: Control = null


func _ready() -> void:
	# Faz este nó continuar recebendo input mesmo com o jogo pausado,
	# senão não dá pra fechar o menu de pausa depois de abrir.
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Global != null:
		Global.set_total_tasks(5)
		Global.last_survival_time = 0.0
	_ensure_ui_is_loaded()
	_setup_default_tasks()


func _ensure_ui_is_loaded() -> void:
	if find_child("UI", true, false) != null:
		print("[Game] UI already present in scene tree.")
		return

	var ui_instance := UI_SCENE.instantiate()
	add_child(ui_instance)
	print("[Game] UI instantiated and added to the scene.")


func _setup_default_tasks() -> void:
	var player := get_node_or_null("Player") as Player
	if player == null:
		return

	if not player.has_task("Coletar garrafa"):
		player.add_task(Task.new("Coletar garrafa", "Entregue a garrafa reciclável na estação.", false, "bottle", 1))

	if not player.has_task("Coletar bateria"):
		player.add_task(Task.new("Coletar bateria", "Entregue a bateria usada na estação.", false, "battery", 1))

	if not player.has_task("Coletar resíduos"):
		player.add_task(Task.new("Coletar resíduos", "Encontre os itens recicláveis no mapa e entregue na estação."))

	if not player.has_task("Limpar a floresta"):
		player.add_task(Task.new("Limpar a floresta", "Remova os resíduos que estão poluindo a área natural."))

	if not player.has_task("Plantar árvores"):
		player.add_task(Task.new("Plantar árvores", "Ajude a restaurar a vegetação da região."))

	if Global != null:
		Global.total_tasks = max(5, player.tasks.size())
		Global.completed_tasks = player.get_completed_task_count() if player.has_method("get_completed_task_count") else 0


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if get_tree().paused:
			fechar_pause()
		else:
			abrir_pause()


func abrir_pause() -> void:
	if get_tree().paused:
		return

	pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	pause_layer.add_child(pause_menu_instance)

	if pause_menu_instance is Control:
		pause_menu_instance.position = Vector2.ZERO
		pause_menu_instance.size = get_viewport_rect().size

	get_tree().paused = true


func fechar_pause() -> void:
	if pause_menu_instance:
		pause_menu_instance.queue_free()
		pause_menu_instance = null

	get_tree().paused = false
