extends Node2D

## Cor e fundo da fase guiados pela posição X do player:
## zonas 1-2 poluídas (escuras/avermelhadas, ruínas), zona 3 transição, zonas 4-5 cidade verde.
##
## Parallax feito à mão: cada fundo é um Sprite2D com a textura repetida 3 vezes
## (region + texture_repeat). A cada quadro o sprite é reposicionado a partir da câmera,
## então sempre há imagem cobrindo a tela.

## 0 = fundo parado na tela, 1 = fundo anda junto com o chão.
const FATOR_PARALLAX := 0.3

## Largura de UMA cópia de cada fundo no mundo (px). Escala = mesma altura (230,4 px).
const LARGURA_RUINAS := 2752.0 * 0.15
const LARGURA_VERDE := 1679.0 * 0.24589
## A cidade verde repete espelhada (texture_repeat = Mirror) porque as bordas da imagem
## não emendam; o padrão só se repete a cada 2 cópias.
const PERIODO_VERDE := LARGURA_VERDE * 2.0

## Desloca o fundo de ruínas para o trecho mais bonito (o oásis) aparecer no começo.
## (O oásis fica a ~207 px da borda esquerda da imagem; com o Leco no início, x ≈ 56.)
const DESLOCAMENTO_RUINAS := -190.0

## A cidade verde aparece aos poucos entre estes X (px): começa na zona 2 e
## fica completa no meio da zona 4.
const VERDE_INICIO_X := 760.0
const VERDE_FIM_X := 1760.0

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

## Tom extra do fundo de ruínas (multiplica com a cor do mundo).
const CORES_RUINAS: Array[Color] = [
	Color(0.80, 0.70, 0.60),
	Color(0.90, 0.62, 0.50),
	Color(1.0, 0.95, 0.90),
	Color(1.0, 1.0, 1.0),
	Color(1.0, 1.0, 1.0),
]

## Cor do topo do céu de cada imagem, usada no céu acima das imagens (cor de fundo da tela).
const CEU_RUINAS := Color(0.29, 0.55, 0.71)
const CEU_VERDE := Color(0.33, 0.58, 0.73)

@onready var canvas_modulate: CanvasModulate = $CanvasModulate
@onready var ruinas: Sprite2D = $Ruinas
@onready var cidade_verde: Sprite2D = $CidadeVerde

var player: Node2D


func _ready() -> void:
	_aplicar_cores(CENTROS_X[0])


func _process(_delta: float) -> void:
	# O player entra no grupo "player" no _ready dele, que pode rodar depois deste.
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if player != null:
		_aplicar_cores(player.global_position.x)

	var camera := get_viewport().get_camera_2d()
	if camera != null:
		var centro_x := camera.get_screen_center_position().x
		var meia_tela := get_viewport_rect().size.x / camera.zoom.x * 0.5
		_posicionar(ruinas, LARGURA_RUINAS, DESLOCAMENTO_RUINAS, centro_x, meia_tela)
		_posicionar(cidade_verde, PERIODO_VERDE, 0.0, centro_x, meia_tela)


## Põe o sprite (cópias lado a lado) de forma que o 1º período comece à esquerda da tela.
## O sprite precisa ter pelo menos 2 períodos de largura na região.
func _posicionar(sprite: Sprite2D, largura: float, deslocamento: float, centro_x: float, meia_tela: float) -> void:
	var base := centro_x * (1.0 - FATOR_PARALLAX) + deslocamento
	var k := floorf((centro_x - meia_tela - base) / largura)
	sprite.position.x = base + k * largura


func _aplicar_cores(x: float) -> void:
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
				t = smoothstep(CENTROS_X[k], CENTROS_X[k + 1], x)
				break

	var cor_mundo := CORES_MUNDO[i].lerp(CORES_MUNDO[i + 1], t)
	var cor_ruinas := CORES_RUINAS[i].lerp(CORES_RUINAS[i + 1], t)
	var verde := smoothstep(VERDE_INICIO_X, VERDE_FIM_X, x)

	canvas_modulate.color = cor_mundo
	ruinas.modulate = cor_ruinas
	cidade_verde.modulate = Color(1.0, 1.0, 1.0, verde)
	RenderingServer.set_default_clear_color((CEU_RUINAS * cor_ruinas).lerp(CEU_VERDE, verde) * cor_mundo)
