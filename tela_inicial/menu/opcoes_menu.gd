extends Control

var configuracoes = preload("res://tela_inicial/configuracoes/configuracoes.tscn")
var pontuacoes = preload("res://tela_inicial/pontuacao/Pontuacoes.tscn")


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

	var container = $CenterContainer/VBoxContainer

	for botao in container.get_children():
		if botao is Button:
			match botao.text:
				"CONTINUAR":
					botao.pressed.connect(_on_btn_continuar_pressed)

				"CONFIGURAÇÕES":
					botao.pressed.connect(_on_btn_configuracoes_pressed)

				"PONTUAÇÃO":
					botao.pressed.connect(_on_btn_pontuacao_pressed)

				"VOLTAR AO LOBBY":
					botao.pressed.connect(_on_btn_voltar_pressed)


func _on_btn_continuar_pressed() -> void:
	get_tree().paused = false
	queue_free()


func _on_btn_configuracoes_pressed() -> void:
	var menu = configuracoes.instantiate()
	add_child(menu)
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _on_btn_pontuacao_pressed() -> void:
	var menu = pontuacoes.instantiate()
	add_child(menu)
	menu.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


func _on_btn_voltar_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://tela_inicial/main_menu.tscn")
