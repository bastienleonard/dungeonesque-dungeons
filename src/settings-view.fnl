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

(local colors (require :colors))
(local enum (require :enum))
(local EventHandlers (require :event-handlers))
(local fonts (require :fonts))
(local Rect (require :rect))
(local scaled (require :screen-scaling))
(local utils (require :utils))

(local ICON-SIZE (scaled 128))

(local Kind (enum :BOOLEAN :CHOICE))

(lambda make-view-rect [view]
  (Rect.new view.x view.y view.width view.height))

(lambda make-settings-config []
  [{:label "Fullscreen"
    :kind Kind.BOOLEAN
    :value love.window.getFullscreen
    :toggle #(love.window.setFullscreen (not (love.window.getFullscreen)))}

   ;; TODO: support adaptive sync (love.window.getVSync = -1)
   {:label "VSync"
    :kind Kind.BOOLEAN
    :value #(= (love.window.getVSync) 1)
    :toggle #(love.window.setVSync (if ($1.value)
                                       0
                                       1))}

   {:label "Show tile contents"
    :kind Kind.BOOLEAN
    :value #config.show-tile-contents?
    :toggle #(set config.show-tile-contents? (not config.show-tile-contents?))}

   {:label "FPS"
    :kind Kind.BOOLEAN
    :value #config.show-fps?
    :toggle #(set config.show-fps? (not config.show-fps?))}

   {:label "Frame durations"
    :kind Kind.BOOLEAN
    :value #config.show-frame-durations?
    :toggle #(set config.show-frame-durations?
                  (not config.show-frame-durations?))}])

(local BooleanSettingView
       (let [class {}]
         (lambda class.new [api config x y width font]
           (setmetatable {:api api
                          :x x
                          :y y
                          :width width
                          :height (font:getHeight)
                          :%config config
                          :%font font}
                         {:__index class}))

         (lambda class.draw [self]
           (love.graphics.print self.%config.label self.%font self.x self.y)
           (let [tile (. tileset
                         (if (self.%config.value)
                             :ui-checkbox-on
                             :ui-checkbox-off))
                 [tile-row tile-column] tile
                 scale-x (utils.round (/ ICON-SIZE tileset.tile-width))
                 scale-y (utils.round (/ ICON-SIZE tileset.tile-height))
                 quad (love.graphics.newQuad (* tile-column tileset.tile-width)
                                             (* tile-row tileset.tile-height)
                                             tileset.tile-width
                                             tileset.tile-height
                                             tileset.width
                                             tileset.height)]
             (love.graphics.draw tileset.image
                                 quad
                                 (- self.width ICON-SIZE)
                                 self.y
                                 0
                                 scale-x
                                 scale-y))
           nil)

         (lambda class.mouse-pressed [self x y]
           (self.%config:toggle)
           nil)

         class))

(local DropdownView
       (let [class {}]
         (lambda class.new [x y width height items font on-item-click]
           (setmetatable {:x x
                          :y y
                          :width width
                          :height height
                          :%items items
                          :%font font
                          :%on-item-click on-item-click}
                         {:__index class}))

         (lambda class.draw [self]
           (utils.with-saved-color
            (lambda []
              (love.graphics.setColor (unpack colors.BLACK))
              (love.graphics.rectangle :fill
                                       self.x
                                       self.y
                                       self.width
                                       self.height)))
           (var y self.y)
           (each [i item (ipairs self.%items)]
             (love.graphics.print item.repr
                                  self.%font
                                  (- (+ self.x self.width)
                                     (self.%font:getWidth item.repr))
                                  y)
             (set y (+ y (self.%font:getHeight))))
           nil)

         (lambda class.mouse-pressed [self x y]
           (let [y (- y self.y)
                 item-index (math.floor (/ y (self.%font:getHeight)))
                 item (. self.%items (+ item-index 1))]
             (self.%on-item-click item))
           nil)

         class))

(local ChoiceSettingView
       (let [class {}]
         (lambda draw-current [self]
           (let [current-choice (self.%config.current)]
             (love.graphics.print current-choice
                                  self.%font
                                  (- (+ self.x self.width)
                                     (self.%font:getWidth current-choice))
                                  self.y))
           nil)

         (lambda draw-dropdown [self]
           (self.%dropdown:draw)
           nil)

         (lambda mouse-pressed-dropdown [self x y]
           (set self.open? false)
           (self.api.pop-event-handler)

           (when (not= self.%dropdown nil)
             (when (: (make-view-rect self.%dropdown) :contains? x y)
               (self.%dropdown:mouse-pressed x y)))
           nil)

         (lambda make-dropdown [parent-x
                                parent-y
                                parent-width
                                items
                                font
                                on-item-click]
           (local dropdown-y parent-y)
           (var dropdown-width 0)
           (var dropdown-height 0)
           (each [i item (ipairs items)]
             (let [item-width (font:getWidth item.repr)]
               (when (> item-width dropdown-width)
                 (set dropdown-width item-width)))
             (set dropdown-height (+ dropdown-height (font:getHeight))))
           (local dropdown-x (- (+ parent-x parent-width)
                                dropdown-width))
           (DropdownView.new dropdown-x
                             dropdown-y
                             dropdown-width
                             dropdown-height
                             items
                             font
                             on-item-click))

         (lambda on-item-click [self item]
           (print item.repr item.value.width item.value.height)
           (self.%config.update item.value)
           nil)

         (lambda class.new [api config x y width font]
           (let [self {:api api
                       :x x
                       :y y
                       :width width
                       :height (font:getHeight)
                       :open? false
                       :%config config
                       :%font font}
                 dropdown (make-dropdown x
                                         y
                                         width
                                         config.items
                                         font
                                         (lambda [item]
                                           (on-item-click self item)
                                           nil))]
                 (set self.%dropdown dropdown)
                 (setmetatable self
                               {:__index class})))

         (lambda class.draw [self]
           (love.graphics.print self.%config.label self.%font self.x self.y)

           (when (not self.open?)
             (draw-current self))

           nil)

         (lambda class.mouse-pressed [self x y]
           (if self.open?
               (self.api.pop-event-handler)
               (self.api.push-event-handler
                {:draw #(draw-dropdown self)
                 :mouse-pressed (lambda [settings-view x y]
                                  (mouse-pressed-dropdown self x y))}))

           (set self.open? (not self.open?))
           nil)

         class))

(lambda make-setting-view [api config x y width font]
  (let [kind config.kind]
    (match kind
      Kind.BOOLEAN (BooleanSettingView.new api config x y width font)
      Kind.CHOICE (ChoiceSettingView.new api config x y width font)
      _ (error (: "make-setting-view: unhandled config kind %s"
                  :format
                  kind)))))

(let [class {}]
  (lambda class.new [x y width height]
    (let [font (fonts.get 100)
          settings-config (make-settings-config)
          setting-views []
          self {:x x
                :y y
                :width width
                :height height
                :%settings-config settings-config
                :%setting-views setting-views
                :%font font
                :%event-handlers (EventHandlers.new)}
          api {:push-event-handler (lambda [handler]
                                     (self.%event-handlers:push handler)
                                     nil)
               :pop-event-handler (lambda []
                                    (self.%event-handlers:pop)
                                    nil)}]
      (var setting-view-y (font:getHeight))
      (each [i setting-config (ipairs settings-config)]
        (let [setting-view (make-setting-view api
                                              setting-config
                                              x
                                              setting-view-y
                                              width
                                              font)]
          (tset setting-views i setting-view)
          (set setting-view-y (+ setting-view-y setting-view.height))))
      (setmetatable self
                    {:__index class
                     :__tostring #:SettingsView})))

  (lambda class.draw [self]
    (let []
      (var y self.y)
      (love.graphics.print "Settings"
                           self.%font
                           (/ (- self.width (font:getWidth "Settings")) 2)
                           y)
      (set y (+ y (font:getHeight)))
      (each [i setting-view (ipairs self.%setting-views)]
        (setting-view:draw)
        (set y (+ y setting-view.height))))

    (when (self.%event-handlers:any?)
      (: (self.%event-handlers:current) :draw))

    nil)

  (lambda class.mouse-pressed [self x y button is-touch presses]
    (if (self.%event-handlers:any?)
      (: (self.%event-handlers:current) :mouse-pressed x y)
      (each [i setting-view (ipairs self.%setting-views)]
        (when (: (make-view-rect setting-view) :contains? x y)
          (setting-view:mouse-pressed x y)
          (lua :break))))
    nil)
  class)
