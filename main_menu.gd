extends Control

func _ready():
	$CenterContainer/VBoxContainer/BtnJogar.pressed.connect(_on_jogar_pressed)
	$CenterContainer/VBoxContainer/BtnConfiguracoes.pressed.connect(_on_configuracoes_pressed)
	$CenterContainer/VBoxContainer/BtnPontuacoes.pressed.connect(_on_pontuacoes_pressed)
	$CenterContainer/VBoxContainer/BtnSair.pressed.connect(_on_sair_pressed)

func _on_jogar_pressed():
	get_tree().change_scene_to_file("res://Teste.tscn")

func _on_configuracoes_pressed():
	get_tree().change_scene_to_file("res://configuracoes.tscn")

func _on_pontuacoes_pressed():
	get_tree().change_scene_to_file("res://Pontuacoes.tscn")

func _on_sair_pressed():
	get_tree().quit()
