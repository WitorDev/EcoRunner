extends Node2D

## Cor e fundo da fase guiados pela posição X do player:
## zonas 1-2 poluídas (escuras/avermelhadas, ruínas), zona 3 transição, zonas 4-5 cidade verde.
## Os valores abaixo são por zona; entre os centros das zonas a cor é interpolada.

## Centro de cada zona em pixels (zonas de 30 tiles = 480 px).
const CENTROS_X: Array[float] = [240.0, 720.0, 1200.0, 1680.0, 2160.0]

## Cor de todo o mundo do jogo (CanvasModulate). Branco = cor original.
const CORES_MUNDO: Array[Color] = [
	Color(0.78, 0.72, 0.64), # 1 poluída: marrom acinzentado
	Color(0.86, 0.66, 0.56), # 2 apocalíptica: avermelhada (fogo)
	Color(0.93, 0.91, 0.87), # 3 transição
	Color(1.0, 1.0, 1.0),    # 4 cidade verde
	Color(1.0, 1.0, 1.0),    # 5 cidade verde
]

## Tom extra do fundo de ruínas (soma com a cor do mundo).
const CORES_RUINAS: Array[Color] = [
	Color(0.80, 0.70, 0.60),
	Color(0.90, 0.62, 0.50),
	Color(1.0, 0.95, 0.90),
	Color(1.0, 1.0, 1.0),
	Color(1.0, 1.0, 1.0),
]

## Opacidade do fundo de cidade verde (0 = só ruínas, 1 = só cidade verde).
const OPACIDADE_VERDE: Array[float] = [0.0, 0.0, 0.5, 1.0, 1.0]

## Cor do topo do céu de cada imagem, usada no céu acima das imagens (cor de fundo da tela).
const CEU_RUINAS := Color(0.29, 0.55, 0.71)
const CEU_VERDE := Color(0.37, 0.72, 0.93)

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var ruinas: Parallax2D = $Ruinas
@onready var cidade_verde: Parallax2D = $CidadeVerde

var player: Node2D


func _ready() -> void:
	_aplicar(CENTROS_X[0])


func _process(_delta: float) -> void:
	# O player entra no grupo "player" no _ready dele, que pode rodar depois deste.
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
		if player == null:
			return
	_aplicar(player.global_position.x)


func _aplicar(x: float) -> void:
	var i := 0
	var t := 0.0
	var ultimo := CENTROS_X.size() - 1
	if x >= CENTROS_X[ultimo]:
		i = ultimo - 1
		t = 1.0
	elif x > CENTROS_X[0]:
		for k in ultimo:
			if x < CENTROS_X[k + 1]:
				i = k
				t = (x - CENTROS_X[k]) / (CENTROS_X[k + 1] - CENTROS_X[k])
				break

	var cor_mundo := CORES_MUNDO[i].lerp(CORES_MUNDO[i + 1], t)
	var cor_ruinas := CORES_RUINAS[i].lerp(CORES_RUINAS[i + 1], t)
	var verde := lerpf(OPACIDADE_VERDE[i], OPACIDADE_VERDE[i + 1], t)

	canvas_modulate.color = cor_mundo
	ruinas.modulate = cor_ruinas
	cidade_verde.modulate = Color(1.0, 1.0, 1.0, verde)
	RenderingServer.set_default_clear_color((CEU_RUINAS * cor_ruinas).lerp(CEU_VERDE, verde) * cor_mundo)
