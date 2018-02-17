module Colors exposing (..)

import Hex
import Color exposing (Color, rgba, linear, toRgb)
import String exposing (padRight)

white : Color
white = 
  rgba 255 255 255 1.0

whiteHex : String
whiteHex =
  toHex white

black : Color
black = 
  rgba 0 0 0 1.0

blackHex : String
blackHex =
  toHex black

green : Color
green = 
  rgba 1 255 137 1.0

greenHex : String
greenHex =
  toHex green

purple : Color
purple =
  rgba 122 95 255 1.0

purpleHex : String
purpleHex =
  toHex purple

turquoise : Color
turquoise =
  rgba 107 220 224 1.0

turquoiseHex : String
turquoiseHex =
  toHex turquoise

hex : Int -> String
hex i =
  padRight 2 '0' (Hex.toString i)

toHex : Color -> String
toHex color =
  let
    rgb = toRgb color
  in
    "#" ++ (hex rgb.red) ++ (hex rgb.green) ++ (hex rgb.blue)
