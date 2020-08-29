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

(lambda love.conf [t]
  (set t.window.fullscreen true)
  (set t.window.width 1920)
  (set t.window.height 1080)
  (set t.window.title "Dungeonesque dungeons")
  (set t.window.icon nil)
  (set t.window.resizable true)

  ;; (set t.window.vsync false)

  ;; TODO: review which modules can be disabled
  ;; (set t.modules.audio true)
  ;; (set t.modules.data true)
  ;; (set t.modules.event true)
  ;; (set t.modules.font true)
  ;; (set t.modules.graphics true)
  ;; (set t.modules.image true)
  ;; (set t.modules.joystick true)
  ;; (set t.modules.keyboard true)
  ;; (set t.modules.math true)
  ;; (set t.modules.mouse true)
  ;; (set t.modules.physics true)
  ;; (set t.modules.sound true)
  ;; (set t.modules.system true)
  ;; (set t.modules.thread true)
  ;; (set t.modules.timer true)
  ;; (set t.modules.touch true)
  ;; (set t.modules.video true)
  ;; (set t.modules.window true)
  )

nil
