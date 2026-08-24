extends Control


func _ready() -> void:
	$CenterContainer/VBoxContainer/BtnJogar.pressed.connect(_on_btn_jogar_pressed)
	$CenterContainer/VBoxContainer/BtnConfiguracoes.pressed.connect(_on_btn_configuracoes_pressed)
	$CenterContainer/VBoxContainer/BtnPontuacoes.pressed.connect(_on_btn_pontuacoes_pressed)
	$CenterContainer/VBoxContainer/BtnSair.pressed.connect(_on_btn_sair_pressed)


func _on_btn_jogar_pressed() -> void:
	get_tree().change_scene_to_file("res://Teste.tscn")


func _on_btn_configuracoes_pressed() -> void:
	get_tree().change_scene_to_file("res://configuracoes.tscn")


func _on_btn_pontuacoes_pressed() -> void:
	get_tree().change_scene_to_file("res://Pontuacoes.tscn")


func _on_btn_sair_pressed() -> void:
	get_tree().quit()
