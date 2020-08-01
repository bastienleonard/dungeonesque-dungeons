(local utils (require :utils))

(lambda screen-size []
  (let [(width height flags) (love.window.getMode)]
    (when (not flags.fullscreen)
      (love.window.setFullscreen true))
    (let [(fullscreen-width fullscreen-height) (love.window.getMode)]
      (when (not flags.fullscreen)
        (love.window.setMode width height flags))
      (values fullscreen-width fullscreen-height))))

(lambda guess-scale []
  (let [(width height) (screen-size)
        guessed-scale (/ height 2160)]
    (print (: "Guessed screen scaling factor: %s for screen size %sx%s"
              :format
              guessed-scale
              width
              height))
    guessed-scale))

(local scale (guess-scale))

(lambda scaled [n]
  (utils.round (* n scale)))

scaled
