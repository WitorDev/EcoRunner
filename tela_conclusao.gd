extends Control

var venceu: bool = false
var tempo_final: float = 0.0


func _ready() -> void:
	$CenterContainer/VBoxContainer/BtnJogarNovamente.pressed.connect(_on_jogar_novamente_pressed)
	$CenterContainer/VBoxContainer/BtnMenuInicial.pressed.connect(_on_menu_inicial_pressed)

	if Global != null:
		tempo_final = Global.last_survival_time
		# Vitória = todas as missões concluídas; se chegou aqui sem isso, o Leco morreu.
		venceu = Global.is_game_finished

	atualizar_tela()


func atualizar_tela() -> void:
	if venceu:
		$CenterContainer/VBoxContainer/Titulo.text = "VOCÊ VENCEU!"
		$CenterContainer/VBoxContainer/Tempo.text = "TEMPO DE CONCLUSÃO\n%s" % Global.format_time(tempo_final)
		$CenterContainer/VBoxContainer/BtnJogarNovamente.text = "JOGAR NOVAMENTE"
	else:
		$CenterContainer/VBoxContainer/Titulo.text = "VOCÊ PERDEU!"
		$CenterContainer/VBoxContainer/Tempo.text = "TEMPO JOGADO\n%s" % Global.format_time(tempo_final)
		$CenterContainer/VBoxContainer/BtnJogarNovamente.text = "TENTAR NOVAMENTE"


func _on_jogar_novamente_pressed() -> void:
	var error := get_tree().change_scene_to_file("res://principal/jogo.tscn")
	if error != OK:
		push_error("Não foi possível reiniciar a fase. Código: %s" % error)


func _on_menu_inicial_pressed() -> void:
	var error := get_tree().change_scene_to_file("res://tela_inicial/main_menu.tscn")
	if error != OK:
		push_error("Não foi possível voltar ao menu inicial. Código: %s" % error)
