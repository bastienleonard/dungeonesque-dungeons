;; Copyright 2020 Bastien Léonard. All rights reserved.

;; Redistribution and use in source and binary forms, with or without
;; modification, are permitted provided that the following conditions
;; are met:

;;    1. Redistributions of source code must retain the above copyright
;;    notice, this list of conditions and the following disclaimer.

;;    2. Redistributions in binary form must reproduce the above
;;    copyright notice, this list of conditions and the following
;;    disclaimer in the documentation and/or other materials provided
;;    with the distribution.

;; THIS SOFTWARE IS PROVIDED BY BASTIEN LÉONARD ``AS IS'' AND ANY
;; EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
;; PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL BASTIEN LÉONARD OR
;; CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
;; SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
;; LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
;; USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
;; ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;; OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
;; OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
;; SUCH DAMAGE.

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
