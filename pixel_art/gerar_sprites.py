"""Gera os sprites de itens e estações das missões (pixel art simples).

Uso (na raiz do projeto):  python pixel_art/gerar_sprites.py
Não precisa de bibliotecas externas. Sobrescreve os PNGs em pixel_art/.

Itens: 16x16. Estações: 128x64 (2 quadros de 64x64: 0 = pendente, 1 = feito).
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

    def elipse(self, cx, cy, rx, ry, c):
        for y in range(int(cy - ry) - 1, int(cy + ry) + 2):
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
    t = Tela(128, 64)
    t.colar(pendente, 0, 0)
    t.colar(feito, 64, 0)
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
    def base():
        t = Tela(64, 64)
        t.elipse(32, 52, 31, 11, "#8d8d7a")
        t.elipse(32, 52, 28, 9, "#2f7fc1")
        t.ret(16, 50, 8, 1, "#7cc6ff")
        t.ret(36, 55, 10, 1, "#7cc6ff")
        t.ret(26, 58, 6, 1, "#7cc6ff")
        for x in (3, 5, 58, 60):
            t.linha(x, 50, x + (1 if x < 32 else -1), 36, "#3f8f2f")
        return t

    vazio = base()
    vazio.contorno()

    lontras = base()
    lontras.elipse(25, 47, 5, 5, "#8a5a34")
    lontras.elipse(26, 49, 3, 2, "#d9b28a")
    lontras.px(24, 45, "#111111")
    lontras.px(28, 45, "#111111")
    lontras.elipse(39, 50, 3.5, 3.5, "#8a5a34")
    lontras.elipse(39.5, 51.5, 2, 1.4, "#d9b28a")
    lontras.px(38, 49, "#111111")
    lontras.px(41, 49, "#111111")
    lontras.contorno()
    for x, y in ((31, 33), (33, 33), (30, 34), (31, 34), (32, 34), (33, 34), (34, 34),
                 (31, 35), (32, 35), (33, 35), (32, 36)):
        lontras.px(x, y, "#e84c6a")
    return folha(vazio, lontras)


if __name__ == "__main__":
    extintor().salvar("extintor.png")
    muda().salvar("muda.png")
    filhote_lontra().salvar("filhote_lontra.png")
    fogo().salvar("fogo.png")
    gerador().salvar("gerador.png")
    canteiro().salvar("canteiro.png")
    rio().salvar("rio.png")
