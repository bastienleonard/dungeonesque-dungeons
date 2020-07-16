(local utils (require :utils))

(let [colors {}]
  (tset colors :ALL [])
  (each [i [color name] (ipairs [[[0 0 0] :BLACK]
                                 [[29 43 83] :DARK-BLUE]
                                 [[126 37 83] :DARK-PURPLE]
                                 [[0 135 81] :DARK-GREEN]
                                 [[171 82 54] :BROWN]
                                 [[95 87 79] :DARK-GRAY]
                                 [[194 195 199] :LIGHT-GRAY]
                                 [[255 241 232] :WHITE]
                                 [[255 0 77] :RED]
                                 [[255 163 0] :ORANGE]
                                 [[255 236 39] :YELLOW]
                                 [[0 228 54] :GREEN]
                                 [[41 173 255] :BLUE]
                                 [[131 118 156] :INDIGO]
                                 [[255 119 168] :PINK]
                                 [[255 204 170] :PEACH]])]
    (let [color (utils.map color (lambda [n] (/ n 255)))]
      (tset colors name color)
      (table.insert colors.ALL color)))
  (tset colors :BACKGROUND-COLOR colors.BLACK)
  colors)
