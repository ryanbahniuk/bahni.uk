module View exposing (..)

import List exposing (map, length)
import String exposing (join)
import Svg exposing (Svg, svg, rect, g, defs, polyline, circle, linearGradient, stop, animate, text, text_)
import Svg.Events exposing (onMouseUp)
import Svg.Attributes exposing (cx, cy, r, x, y, x1, y1, x2, y2, width, height, offset, fill, id, class, attributeName, values, dur, repeatCount, points, stroke, textAnchor)
import Models exposing (Model, Polygon, Vertex, Coordinates)
import Messages exposing (Msg(..))
import Events exposing (onMouseMove, onClick, onStopPropClick, onStopPropMouseDown)
import Helpers exposing (noneInFlight)
import Colors exposing (greenHex, purpleHex, turquoiseHex, whiteHex, blackHex)

view : Model -> Svg Msg
view model =
  svg [ width "100%", height "100%", clickAction model, onMouseMove Track, onMouseUp Lock ]
  [ gradient
  , g [] (map polygonView model.polygons)
  , g [] (map polygonCircleView model.polygons)
  , maskText
  ]

maskText : Svg Msg
maskText =
  Svg.mask [ id "knockout-text" ]
  [ rect [ width "100%", height "100%",  fill whiteHex, x "0", y "0" ] []
  , text_ [ class "intro", x "50%", y "300", fill blackHex, textAnchor "middle" ] [ text introTextFirstLine ]
  , text_ [ class "intro", x "50%", y "350", fill blackHex, textAnchor "middle" ] [ text introTextSecondLine ]
  , text_ [ class "intro", x "50%", y "400", fill blackHex, textAnchor "middle" ] [ text introTextThirdLine ]
  , text_ [ class "intro", x "50%", y "450", fill blackHex, textAnchor "middle" ] [ text introTextFourthLine ]
  , text_ [ class "credit", x "50%", y "700", fill blackHex, textAnchor "middle" ] [ text creditLine ]
  ]

introTextFirstLine : String
introTextFirstLine =
  "hi, i am ryan bahniuk."

introTextSecondLine : String
introTextSecondLine =
  "i'm a developer at braintree,"

introTextThirdLine : String
introTextThirdLine =
  "formerly at wealthfront,"

introTextFourthLine : String
introTextFourthLine =
  "and once upon a time at notre dame."

creditLine : String
creditLine =
  "this site (and other cool things) can be found on my github"

clickAction : Model -> Svg.Attribute Msg
clickAction model =
  if (noneInFlight model.polygons) then
    onClick Add
  else
    onStopPropClick Noop

stopOneAnimationColor : String
stopOneAnimationColor =
  purpleHex ++ "; " ++ greenHex ++ "; " ++ purpleHex

stopTwoAnimationColor : String
stopTwoAnimationColor =
  greenHex ++ "; " ++ purpleHex ++ "; " ++ greenHex

gradient : Svg Msg
gradient =
  defs []
  [ linearGradient [ id "gradient", x1 "0%", y1 "0%", x2 "100%", y2 "0%" ]
    [ stop [ offset "0%", class "stop-one" ]
      [ animate [ attributeName "stop-color", values stopOneAnimationColor, dur "4s", repeatCount "indefinite" ] []
      ]
    , stop [ offset "100%", class "stop-two" ]
      [ animate [ attributeName "stop-color", values stopTwoAnimationColor, dur "4s", repeatCount "indefinite" ] []
      ]
    ]
  ]

polygonView : Polygon -> Svg Msg
polygonView polygon =
  polylineView polygon.vertices

polylineView : List Vertex -> Svg Msg
polylineView vertices =
  polyline [ fill "url(#gradient)", Svg.Attributes.mask "url(#knockout-text)", polylineStroke vertices, class "line", points (polyPoints (map .coordinates vertices)) ] []

polylineStroke : List Vertex -> Svg.Attribute Msg
polylineStroke vertices =
  if (length vertices) > 2 then
    stroke "none"
  else
    stroke turquoiseHex

polyPoints : List Coordinates -> String
polyPoints coordinates =
  join " " (map (\n -> (toString n.x) ++ "," ++ (toString n.y)) coordinates)

polygonCircleView : Polygon -> Svg Msg
polygonCircleView polygon =
  g [] (map (circleView polygon) polygon.vertices)

circleView : Polygon -> Vertex -> Svg Msg
circleView polygon vertex =
  g []
  [ circle [ cx (toString vertex.coordinates.x), cy (toString vertex.coordinates.y), r "10", class "third-circle" ] []
  , circle [ cx (toString vertex.coordinates.x), cy (toString vertex.coordinates.y), r "10", class "second-circle" ] []
  , circle [ cx (toString vertex.coordinates.x), cy (toString vertex.coordinates.y), r "10", class "circle", onStopPropMouseDown (Unlock polygon vertex) ] []
  ]
