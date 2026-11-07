@tool
extends EditorScript

## Gerador do mapa da fase única.
##
## Como usar: abra este script no editor e use File → Run (Ctrl+Shift+X).
## O script abre `mapa/mapa.tscn` sozinho, redesenha e salva a cena.
##
## O script é idempotente: apaga todos os tiles e redesenha a fase inteira.
##
## Cada zona é desenhada em ASCII (1 caractere = 1 tile de 16x16 px):
##   '#'  terreno (com colisão)
##   '.'  vazio
##   letra  marcador (vazio no mapa; a posição é impressa no Output)
##          P = player, N = NPC, I = item, E = estação
## As zonas são coladas lado a lado, da esquerda para a direita.

const CENA_MAPA := "res://mapa/mapa.tscn"
const TAM_TILE := 16
const MEIO_TILE := 8
const TERRAIN_SET := 0
const TERRAIN := 0

## Linha (em tiles) da primeira string de cada zona. A linha 0 é a superfície do
## chão principal: o topo dela fica em y = 0 px.
const PRIMEIRA_LINHA := -8

## Parede provisória depois da última zona, para o player não cair no vazio.
## Desligar quando a fase estiver completa.
const PAREDE_FINAL := true

const ZONA_1: Array[String] = [
	"##............................", # -8
	"##............................", # -7
	"##............................", # -6
	"##............................", # -5
	"##............................", # -4
	"##..............I.............", # -3
	"##..........########..........", # -2
	"##.P..N.....########......E...", # -1
	"####################..########", #  0
	"####################..########", #  1
	"##############################", #  2
	"##############################", #  3
]

const ZONAS: Array = [ZONA_1]


func _run() -> void:
	# Abre (ou troca para) a aba de mapa.tscn, não importa qual cena está ativa.
	EditorInterface.open_scene_from_path(CENA_MAPA)
	var mapa := EditorInterface.get_edited_scene_root() as TileMapLayer
	if mapa == null or mapa.scene_file_path != CENA_MAPA:
		push_error("[gerar_mapa] Não consegui abrir %s como TileMapLayer." % CENA_MAPA)
		return

	mapa.clear()

	var celulas: Array[Vector2i] = []
	var coluna_inicial := 0
	var altura := 0

	for indice_zona in ZONAS.size():
		var zona: Array = ZONAS[indice_zona]
		altura = zona.size()
		var largura := _largura_da_zona(zona, indice_zona)
		for i in zona.size():
			var linha_texto: String = zona[i]
			var y := PRIMEIRA_LINHA + i
			for c in linha_texto.length():
				var ch := linha_texto[c]
				var celula := Vector2i(coluna_inicial + c, y)
				if ch == "#":
					celulas.append(celula)
				elif ch != ".":
					_imprimir_marcador(ch, indice_zona + 1, celula)
		coluna_inicial += largura

	if PAREDE_FINAL:
		for i in altura:
			celulas.append(Vector2i(coluna_inicial, PRIMEIRA_LINHA + i))

	mapa.set_cells_terrain_connect(celulas, TERRAIN_SET, TERRAIN)
	EditorInterface.mark_scene_as_unsaved()
	EditorInterface.save_scene()
	print("[gerar_mapa] Pronto: %d tiles, %d colunas. %s salvo." % [celulas.size(), coluna_inicial, CENA_MAPA])


func _largura_da_zona(zona: Array, indice_zona: int) -> int:
	var largura: int = (zona[0] as String).length()
	for linha_texto in zona:
		if (linha_texto as String).length() != largura:
			push_warning("[gerar_mapa] Zona %d tem linhas de larguras diferentes." % (indice_zona + 1))
	return largura


func _imprimir_marcador(ch: String, zona: int, celula: Vector2i) -> void:
	var centro_x := celula.x * TAM_TILE + MEIO_TILE
	var base_y := (celula.y + 1) * TAM_TILE
	print("[gerar_mapa] Zona %d, '%s': coluna %d, linha %d → x = %d px, chão em y = %d px" % [zona, ch, celula.x, celula.y, centro_x, base_y])
