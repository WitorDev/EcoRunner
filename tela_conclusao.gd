extends Control

var venceu: bool = false
var tempo_final: float = 0.0


func _ready() -> void:
	$CenterContainer/VBoxContainer/BtnJogarNovamente.pressed.connect(_on_jogar_novamente_pressed)
	$CenterContainer/VBoxContainer/BtnMenuInicial.pressed.connect(_on_menu_inicial_pressed)

	atualizar_tela()


func atualizar_tela() -> void:
	var minutos := int(tempo_final) / 60
	var segundos := int(tempo_final) % 60
	
	if venceu:
		$CenterContainer/VBoxContainer/Titulo.text = "VOCÊ VENCEU!"
		
		$CenterContainer/VBoxContainer/Tempo.text = "TEMPO FINAL\n%02d:%02d" % [minutos, segundos]
		
		$CenterContainer/VBoxContainer/BtnJogarNovamente.text = "JOGAR NOVAMENTE"
	else:
		$CenterContainer/VBoxContainer/Titulo.text = "VOCÊ PERDEU!"
		
		$CenterContainer/VBoxContainer/Tempo.text = "Tempo sobrevivido: %02d:%02d" % [minutos, segundos]
		
		$CenterContainer/VBoxContainer/BtnJogarNovamente.text = "TENTAR NOVAMENTE"


func _on_jogar_novamente_pressed() -> void:
	get_tree().change_scene_to_file("res://Teste.tscn")


func _on_menu_inicial_pressed() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")
