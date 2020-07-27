(local utils (require :utils))

(local BORDER-WIDTH 4)
(local ALPHA 1)

(lambda get-refresh-rate []
  (let [(width height flags) (love.window.getMode)]
    flags.refreshrate))

(let [FramesGraphView {}]
  (tset FramesGraphView :new
        (lambda [class]
          (let [width 500
                instance {:width width
                          :height 300
                          :_frame-target (math.floor
                                          (/ 1000 (get-refresh-rate)))
                          :_dts {}
                          :_dts-max (- width (* 2 BORDER-WIDTH))}]
            (setmetatable instance { :__index class })
            instance)))
  (tset FramesGraphView :update
        (lambda [self dt]
          ;; TODO: use a ring buffer
          (table.insert self._dts dt)
          (if (> (length self._dts) self._dts-max)
              (table.remove self._dts 1))
          nil))
  (tset FramesGraphView :draw
        (lambda [self]
          (let [x 0
                right (+ x self.width -1)
                y (- (love.graphics.getHeight) self.height)
                bottom (- (love.graphics.getHeight) 1)
                dt-to-y (lambda [dt]
                          (let [y (* dt 1000)
                                limit (- self.height 1 (* BORDER-WIDTH 2))]
                            (if (>= y limit)
                                limit
                                y)))]

            (utils.with-saved-color (lambda []
              (love.graphics.setColor 0 0 0 ALPHA)
              (love.graphics.rectangle :fill
                                       x
                                       y
                                       (- right x)
                                       (- bottom y))

              (love.graphics.setColor 1 1 1 ALPHA)

              (let [x-start (+ x BORDER-WIDTH)]
                (each [i dt (ipairs self._dts)]
                  (love.graphics.line (+ x-start i -1)
                                      (- bottom BORDER-WIDTH)
                                      (+ x-start i -1)
                                      (- bottom BORDER-WIDTH (dt-to-y dt)))))

              (love.graphics.setColor 1 0 0)
              (love.graphics.rectangle :fill x y self.width BORDER-WIDTH)
              (love.graphics.rectangle :fill
                                       (- right BORDER-WIDTH)
                                       y
                                       BORDER-WIDTH
                                       self.height)
              (love.graphics.rectangle :fill
                                       x
                                       (- bottom BORDER-WIDTH)
                                       self.width
                                       BORDER-WIDTH)
              (love.graphics.rectangle :fill x y BORDER-WIDTH self.height)
              (let [frame-target-y
                    (- bottom
                       (dt-to-y (/ self._frame-target 1000)))]
                (love.graphics.line x
                                    frame-target-y
                                    right
                                    frame-target-y))))
              nil)
            nil))
  FramesGraphView)
