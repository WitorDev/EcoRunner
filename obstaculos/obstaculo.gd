extends Area2D
class_name Obstaculo

## Obstáculo de 1 tile: encostar tira vida do player (1 coração), dá um empurrão para
## fora e deixa o player invencível por um tempo (piscando), para não perder vários
## corações de uma vez.

@export var textura: Texture2D
@export var dano: int = 1
## Segundos sem levar dano depois de um acerto (vale para todos os obstáculos).
@export var tempo_invencivel: float = 1.0
## Empurrão aplicado ao player: x para longe do obstáculo, y para cima.
@export var empurrao: Vector2 = Vector2(160.0, -220.0)

## Metadado guardado no player com o fim da invencibilidade (Time.get_ticks_msec()).
const META_INVENCIVEL := &"invencivel_ate_ms"

@onready var sprite: Sprite2D = $Sprite2D


func _ready() -> void:
	if textura != null:
		sprite.texture = textura


func _physics_process(_delta: float) -> void:
	# Checa a cada quadro (e não só ao entrar) para acertar de novo quem continuar
	# encostado quando a invencibilidade acabar.
	for body in get_overlapping_bodies():
		if body is Player:
			_ferir(body as Player)


func _ferir(player: Player) -> void:
	if player.is_dead:
		return
	var agora := Time.get_ticks_msec()
	if agora < int(player.get_meta(META_INVENCIVEL, 0)):
		return
	player.set_meta(META_INVENCIVEL, agora + int(tempo_invencivel * 1000.0))

	player.take_damage(dano)
	if player.is_dead:
		return

	var direcao := signf(player.global_position.x - global_position.x)
	if direcao == 0.0:
		direcao = -1.0
	player.velocity = Vector2(direcao * empurrao.x, empurrao.y)
	_piscar(player)


func _piscar(player: Player) -> void:
	var vezes := maxi(1, int(tempo_invencivel / 0.2))
	var tween := player.create_tween()
	tween.set_loops(vezes)
	tween.tween_property(player, "modulate:a", 0.3, 0.1)
	tween.tween_property(player, "modulate:a", 1.0, 0.1)
