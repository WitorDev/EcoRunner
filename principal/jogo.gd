extends Node2D

const PAUSE_MENU_SCENE := preload("res://tela_inicial/menu/opcoes_menu.tscn")
const UI_SCENE := preload("res://UI/ui.tscn")

@onready var pause_layer: CanvasLayer = $PauseLayer

var pause_menu_instance: Control = null

const TELA_CONCLUSAO := "res://tela_conclusao.tscn"
## Segundos entre a última entrega e a tela de vitória.
const ESPERA_ANTES_DA_CONCLUSAO := 2.0
var fim_de_jogo: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if Global != null:
		# Zera o placar da partida anterior (senão "Jogar novamente" começa já vencido).
		Global.reset_progress()
		Global.set_total_tasks(5)
		Global.last_survival_time = 0.0
	_ensure_ui_is_loaded()
	_refresh_global_task_count()
	if Global != null:
		Global.game_finished.connect(_on_game_finished)


## Todas as missões concluídas: espera um pouco (para ver o aviso e a estação mudar)
## e abre a tela de conclusão em modo vitória.
func _on_game_finished() -> void:
	if fim_de_jogo:
		return
	fim_de_jogo = true
	var player := get_node_or_null("Player") as Player
	if player != null:
		player.set_physics_process(false)
		Global.last_survival_time = player.survival_time
	await get_tree().create_timer(ESPERA_ANTES_DA_CONCLUSAO).timeout
	if not is_inside_tree():
		return # saiu da fase (ex.: menu de pausa) durante a espera
	var error := get_tree().change_scene_to_file(TELA_CONCLUSAO)
	if error != OK:
		push_error("Não foi possível abrir a tela de conclusão. Código: %s" % error)


func _ensure_ui_is_loaded() -> void:
	if find_child("UI", true, false) != null:
		print("[Game] UI already present in scene tree.")
		return

	var ui_instance := UI_SCENE.instantiate()
	add_child(ui_instance)
	print("[Game] UI instantiated and added to the scene.")


func _refresh_global_task_count() -> void:
	var player := get_node_or_null("Player") as Player
	if player == null:
		return
	if Global != null:
		var completed_count: int = player.get_completed_task_count() if player.has_method("get_completed_task_count") else 0
		Global.update_progress(completed_count, Global.total_tasks)


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
