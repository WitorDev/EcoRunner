"""Gera os sprites de itens e estações das missões (pixel art simples).

Uso (na raiz do projeto):  python pixel_art/gerar_sprites.py
Não precisa de bibliotecas externas. Sobrescreve os PNGs em pixel_art/.

Itens: 16x16. Estações: 128x64 (2 quadros de 64x64: 0 = pendente, 1 = feito).
Exceção: rio.png tem 256x64 (2 quadros de 128x64; em jogo.tscn, frame_size = 128x64).
"""
import os
import struct
import zlib

PASTA = os.path.dirname(os.path.abspath(__file__))
CONTORNO = "#1b1b1b"


def cor(c):
    c = c.lstrip("#")
    if len(c) == 6:
        c += "ff"
    return tuple(int(c[i:i + 2], 16) for i in range(0, 8, 2))


class Tela:
    def __init__(self, w, h):
        self.w, self.h = w, h
        self.p = [[(0, 0, 0, 0)] * w for _ in range(h)]

    def px(self, x, y, c):
        if 0 <= x < self.w and 0 <= y < self.h:
            self.p[y][x] = cor(c)

    def ret(self, x, y, w, h, c):
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                self.px(xx, yy, c)

    def elipse(self, cx, cy, rx, ry, c, y_min=None):
        for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
            if y_min is not None and y < y_min:
                continue
            for x in range(int(cx - rx) - 1, int(cx + rx) + 2):
                if ((x + 0.5 - cx) / rx) ** 2 + ((y + 0.5 - cy) / ry) ** 2 <= 1.0:
                    self.px(x, y, c)

    def linha(self, x0, y0, x1, y1, c, grossura=1):
        dx, dy = abs(x1 - x0), -abs(y1 - y0)
        sx, sy = (1 if x0 < x1 else -1), (1 if y0 < y1 else -1)
        err = dx + dy
        while True:
            self.ret(x0, y0, grossura, grossura, c)
            if x0 == x1 and y0 == y1:
                break
            e2 = 2 * err
            if e2 >= dy:
                err += dy
                x0 += sx
            if e2 <= dx:
                err += dx
                y0 += sy

    def contorno(self, c=CONTORNO):
        opaco = [[a[3] > 0 for a in linha] for linha in self.p]
        for y in range(self.h):
            for x in range(self.w):
                if opaco[y][x]:
                    continue
                for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    nx, ny = x + dx, y + dy
                    if 0 <= nx < self.w and 0 <= ny < self.h and opaco[ny][nx]:
                        self.px(x, y, c)
                        break

    def colar(self, outra, ox, oy):
        for y in range(outra.h):
            for x in range(outra.w):
                if outra.p[y][x][3] > 0:
                    self.p[oy + y][ox + x] = outra.p[y][x]

    def salvar(self, nome):
        raw = b"".join(b"\x00" + bytes(v for p in linha for v in p) for linha in self.p)

        def chunk(t, d):
            return struct.pack(">I", len(d)) + t + d + struct.pack(">I", zlib.crc32(t + d) & 0xFFFFFFFF)

        dados = (b"\x89PNG\r\n\x1a\n"
                 + chunk(b"IHDR", struct.pack(">IIBBBBB", self.w, self.h, 8, 6, 0, 0, 0))
                 + chunk(b"IDAT", zlib.compress(raw, 9))
                 + chunk(b"IEND", b""))
        with open(os.path.join(PASTA, nome), "wb") as f:
            f.write(dados)
        print("gerado:", nome)


def folha(pendente, feito):
    t = Tela(pendente.w * 2, pendente.h)
    t.colar(pendente, 0, 0)
    t.colar(feito, pendente.w, 0)
    return t


# ---------------------------------------------------------------- itens 16x16

def extintor():
    t = Tela(16, 16)
    t.ret(5, 5, 6, 10, "#d62f2f")
    t.ret(6, 6, 1, 8, "#ff6b5b")
    t.ret(10, 5, 1, 10, "#8f1d1d")
    t.ret(5, 9, 6, 2, "#f0f0f0")
    t.ret(6, 3, 4, 2, "#a8a8a8")
    t.ret(5, 2, 5, 1, "#3a3a3a")
    t.linha(9, 2, 12, 1, "#3a3a3a")
    t.linha(10, 4, 13, 6, "#2a2a2a")
    t.linha(13, 6, 13, 9, "#2a2a2a")
    t.px(14, 10, "#2a2a2a")
    t.contorno()
    return t


def muda():
    t = Tela(16, 16)
    t.elipse(8, 13.5, 6, 2.5, "#6b4423")
    t.ret(3, 14, 10, 1, "#4e3018")
    t.linha(8, 12, 8, 5, "#3f8f2f")
    t.elipse(5.5, 8, 2.6, 1.5, "#58c23a")
    t.elipse(10.5, 6, 2.6, 1.5, "#58c23a")
    t.elipse(8, 3.5, 1.2, 1.8, "#7be05a")
    t.contorno()
    return t


def filhote_lontra():
    t = Tela(16, 16)
    t.linha(4, 12, 1, 14, "#6e4528", 2)
    t.elipse(7.5, 11, 5, 3.5, "#8a5a34")
    t.elipse(7.5, 12.2, 3, 1.8, "#d9b28a")
    t.elipse(11, 7, 3, 3, "#8a5a34")
    t.elipse(11.8, 8.2, 2, 1.4, "#d9b28a")
    t.px(9, 4, "#6e4528")
    t.px(12, 6, "#111111")
    t.px(13, 8, "#111111")
    t.ret(5, 14, 2, 1, "#6e4528")
    t.ret(9, 14, 2, 1, "#6e4528")
    t.contorno()
    return t


# ------------------------------------------------------- obstáculos 16x16
# Ficam apoiados no chão (base na linha 15). Encostar tira 1 coração.

def barril_toxico():
    t = Tela(16, 16)
    t.ret(4, 4, 8, 11, "#d9b42c")
    t.ret(5, 5, 1, 9, "#f2d35c")
    t.ret(11, 4, 1, 11, "#9c7f1a")
    t.ret(4, 6, 8, 1, "#3a3a3a")
    t.ret(4, 12, 8, 1, "#3a3a3a")
    t.ret(4, 3, 8, 1, "#9c7f1a")
    t.elipse(8, 9.5, 1.6, 1.6, "#3a3a3a")
    t.ret(2, 15, 12, 1, "#7bdc3c")
    t.ret(10, 14, 4, 1, "#7bdc3c")
    t.ret(6, 2, 2, 2, "#7bdc3c")
    t.px(6, 4, "#7bdc3c")
    t.contorno()
    return t


def chama():
    t = Tela(16, 16)
    t.ret(3, 14, 10, 2, "#5a3a1e")
    t.elipse(8, 11, 5, 4, "#d8341c")
    t.elipse(6, 8, 2.2, 4, "#d8341c")
    t.elipse(10, 7, 2.2, 5, "#d8341c")
    t.elipse(8, 5, 1.6, 4, "#d8341c")
    t.elipse(8, 11.5, 3.2, 2.6, "#f5841f")
    t.elipse(8.5, 8, 1.4, 3, "#f5841f")
    t.elipse(8, 12, 1.6, 1.6, "#ffd23f")
    t.contorno()
    return t


def fio_eletrico():
    t = Tela(16, 16)
    t.linha(0, 13, 4, 14, "#2a2a2a", 2)
    t.linha(4, 14, 9, 12, "#2a2a2a", 2)
    t.ret(10, 12, 2, 1, "#d98b3a")
    t.px(12, 11, "#d98b3a")
    t.px(12, 13, "#d98b3a")
    t.contorno()
    for x0, y0, x1, y1 in ((12, 10, 10, 7), (10, 7, 12, 5), (12, 5, 10, 2),
                           (13, 11, 15, 8), (14, 12, 15, 13)):
        t.linha(x0, y0, x1, y1, "#ffe066")
    t.px(11, 6, "#ffffff")
    return t


def espinhos():
    t = Tela(16, 16)
    t.elipse(8, 11.5, 7, 4.5, "#2f6e2b")
    t.elipse(7, 10.5, 4, 2.5, "#3f8f2f")
    for x, y in ((2, 9), (5, 6), (8, 6), (11, 6), (14, 9), (1, 12), (15, 12), (10, 8), (4, 9)):
        t.px(x, y, "#efe6c8")
        t.px(x, y - 1 if y > 7 else y, "#efe6c8")
    t.contorno()
    return t


# ----------------------------------------------------------- estações 64x64

def fogo():
    def lenha(t, c1, c2):
        t.linha(14, 61, 50, 55, c1, 4)
        t.linha(14, 55, 50, 61, c2, 4)

    aceso = Tela(64, 64)
    lenha(aceso, "#5a3a1e", "#6e4826")
    for cx, cy, rx, ry in ((32, 46, 17, 13), (23, 38, 7, 13), (41, 36, 7, 15), (32, 30, 6, 18)):
        aceso.elipse(cx, cy, rx, ry, "#d8341c")
    for cx, cy, rx, ry in ((32, 48, 12, 9), (27, 40, 4, 9), (37, 38, 4, 10), (32, 36, 4, 11)):
        aceso.elipse(cx, cy, rx, ry, "#f5841f")
    for cx, cy, rx, ry in ((32, 51, 7, 5), (32, 45, 3, 7)):
        aceso.elipse(cx, cy, rx, ry, "#ffd23f")
    aceso.contorno()
    for x, y in ((18, 22), (46, 18), (40, 10), (22, 12)):
        aceso.px(x, y, "#ffb02e")

    apagado = Tela(64, 64)
    lenha(apagado, "#2b2420", "#3a302a")
    for x, y in ((24, 57), (31, 58), (38, 56), (44, 58)):
        apagado.px(x, y, "#9a3a1a")
    apagado.contorno()
    for cx, cy, r, c in ((32, 47, 5, "#8c8c8ccc"), (36, 39, 4, "#a0a0a0b0"),
                         (31, 31, 3.5, "#b4b4b499"), (35, 24, 3, "#c8c8c880")):
        apagado.elipse(cx, cy, r, r, c)
    return folha(aceso, apagado)


def gerador():
    def base(ligado):
        t = Tela(64, 64)
        t.ret(12, 59, 6, 4, "#2a2f35")
        t.ret(46, 59, 6, 4, "#2a2f35")
        t.ret(10, 26, 44, 33, "#5d6670")
        t.ret(10, 26, 44, 4, "#7b8590")
        t.ret(16, 34, 20, 18, "#11331d" if ligado else "#2a2f35")
        for y in range(36, 50, 3):
            t.ret(40, y, 10, 1, "#3f464e")
        t.elipse(45, 31.5, 2, 2, "#2ecc71" if ligado else "#c0392b")
        raio = "#ffd23f" if ligado else "#4a4f55"
        t.linha(29, 36, 22, 43, raio, 2)
        t.linha(22, 43, 29, 43, raio, 2)
        t.linha(29, 43, 23, 50, raio, 2)
        t.contorno()
        if ligado:
            for x0, y0, x1, y1 in ((20, 20, 17, 15), (32, 19, 32, 13), (44, 20, 47, 15)):
                t.linha(x0, y0, x1, y1, "#ffe066")
        return t

    return folha(base(False), base(True))


def canteiro():
    def base():
        t = Tela(64, 64)
        t.ret(4, 50, 56, 13, "#8b5a2b")
        t.ret(7, 52, 50, 9, "#5b3a1f")
        for x in (4, 18, 32, 46, 59):
            t.ret(x, 50, 1, 13, "#6b4220")
        t.ret(4, 50, 56, 1, "#a87040")
        return t

    vazio = base()
    vazio.elipse(32, 55.5, 4, 1.6, "#3a2414")
    vazio.contorno()

    arvore = base()
    arvore.ret(29, 32, 6, 21, "#6b4423")
    arvore.ret(30, 32, 1, 21, "#8a5a34")
    arvore.elipse(32, 22, 17, 13, "#3f9e3a")
    arvore.elipse(38, 27, 8, 5, "#2f7a2b")
    arvore.elipse(26, 17, 8, 6, "#58c23a")
    arvore.contorno()
    for x, y in ((22, 24), (40, 16), (33, 12)):
        arvore.px(x, y, "#e84c6a")
    return folha(vazio, arvore)


def rio():
    """Lago de 128x64 por quadro, afundado no chão.

    A superfície da água fica na linha SUPERFICIE do quadro; no jogo a estação é posta
    em y = chão - 8, então essa linha coincide com o topo do chão e a água "entra" nele.
    """
    SUPERFICIE = 40

    def quadro(com_lontras):
        t = Tela(128, 64)
        # margem de terra e pedras (bacia)
        t.elipse(64, SUPERFICIE, 63, 23, "#5b3a1f", y_min=SUPERFICIE)
        t.elipse(64, SUPERFICIE, 61, 21, "#7a7466", y_min=SUPERFICIE)

        enfeites = Tela(128, 64)
        for x in (6, 10, 14, 113, 117, 121):
            topo = 22 + (x % 3) * 3
            enfeites.linha(x, SUPERFICIE + 1, x, topo, "#3f8f2f")
            enfeites.ret(x, topo - 3, 1, 3, "#6b4423")
        if com_lontras:
            enfeites.elipse(54, 37, 5.5, 5.5, "#8a5a34")
            enfeites.elipse(55, 39, 3.2, 2, "#d9b28a")
            enfeites.px(52, 35, "#111111")
            enfeites.px(57, 35, "#111111")
            enfeites.elipse(72, 38.5, 3.8, 3.8, "#8a5a34")
            enfeites.elipse(72.5, 40, 2.2, 1.4, "#d9b28a")
            enfeites.px(71, 37, "#111111")
            enfeites.px(74, 37, "#111111")
        enfeites.contorno()
        t.colar(enfeites, 0, 0)

        # água por cima (cobre a parte de baixo das lontras)
        t.elipse(64, SUPERFICIE, 59, 19, "#2f7fc1", y_min=SUPERFICIE + 1)
        t.elipse(64, SUPERFICIE + 2, 44, 13, "#25689f", y_min=SUPERFICIE + 6)
        t.ret(6, SUPERFICIE, 116, 1, "#7cc6ff")
        for x, y, w in ((22, 46, 12), (80, 48, 14), (48, 53, 10), (90, 54, 6)):
            t.ret(x, y, w, 1, "#7cc6ff")
        t.elipse(98, SUPERFICIE + 1, 5, 1.6, "#3f9e3a")
        if com_lontras:
            for x, w in ((46, 4), (60, 4), (66, 3), (77, 3)):
                t.ret(x, SUPERFICIE + 2, w, 1, "#cfefff")
            for x, y in ((62, 19), (64, 19), (61, 20), (62, 20), (63, 20), (64, 20), (65, 20),
                         (62, 21), (63, 21), (64, 21), (63, 22)):
                t.px(x, y, "#e84c6a")
        return t

    return folha(quadro(False), quadro(True))


if __name__ == "__main__":
    extintor().salvar("extintor.png")
    muda().salvar("muda.png")
    filhote_lontra().salvar("filhote_lontra.png")
    fogo().salvar("fogo.png")
    gerador().salvar("gerador.png")
    canteiro().salvar("canteiro.png")
    rio().salvar("rio.png")
    barril_toxico().salvar("obstaculo_barril.png")
    chama().salvar("obstaculo_chama.png")
    fio_eletrico().salvar("obstaculo_fio.png")
    espinhos().salvar("obstaculo_espinhos.png")
