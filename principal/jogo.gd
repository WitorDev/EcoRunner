extends Node2D

const PAUSE_MENU_SCENE := preload("res://tela_inicial/menu/opcoes_menu.tscn")

@onready var pause_layer: CanvasLayer = $PauseLayer

var pause_menu_instance: Control = null


func _ready() -> void:
	# Faz este nó continuar recebendo input mesmo com o jogo pausado,
	# senão não dá pra fechar o menu de pausa depois de abrir.
	process_mode = Node.PROCESS_MODE_ALWAYS


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
