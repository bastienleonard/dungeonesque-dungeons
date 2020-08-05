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

(local SettingsView (require :settings-view))

(let [class {}]
  (lambda class.new []
    (setmetatable {:%settings-view (SettingsView.new)}
                  {:__index class
                   :__tostring #:SettingsScreen}))
  (lambda class.draw [self]
    (self.%settings-view:draw)
    nil)
  (lambda class.key-pressed [self key scancode is-repeat]
    (when (= key :escape)
      (screens:pop))
    nil)
  (lambda class.mouse-pressed [self x y button is-touch presses]
    (self.%settings-view:mouse-pressed x y button is-touch presses)
    nil)
  class)
