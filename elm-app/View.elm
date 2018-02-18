module View exposing (..)

import List exposing (map, length, any)
import String exposing (join)
import VirtualDom exposing (attribute)
import Svg exposing (Svg, Attribute, svg, path, a, rect, g, defs, polyline, circle, linearGradient, stop, animate, text, text_)
import Svg.Events exposing (onMouseUp)
import Svg.Attributes exposing (d, cx, cy, r, x, y, x1, y1, x2, y2, width, height, offset, fill, id, class, attributeName, values, dur, repeatCount, points, stroke, textAnchor, fillRule, transform, target)
import Models exposing (Model, Cursor, Polygon, Vertex, Coordinates)
import Messages exposing (Msg(..))
import Events exposing (onMouseMove, onClick, onStopPropClick, onStopPropMouseDown)
import Helpers exposing (noneInFlight, flattenVertices)
import Colors exposing (greenHex, purpleHex, turquoiseHex, whiteHex, blackHex, lightGreyHex)

view : Model -> Svg Msg
view model =
  svg [ width "100%", height "100%", clickAction model, onMouseMove Track, onMouseUp Lock ]
  [ gradient
  , g [] (map polygonView model.polygons)
  , g [] (map polygonCircleView model.polygons)
  , maybeCursorView model
  , maskText
  , twitter model.twitterCoordinates
  , github model.githubCoordinates
  ]

twitter : Coordinates -> Svg Msg
twitter coordinates =
  a [ class "social-icon", href "https://twitter.com/ryanbahniuk", target "_blank" ]
  [ svg [ x (toString coordinates.x), y (toString coordinates.y) ]
    [ g [] [ circle [ transform "scale(0.1)", fill lightGreyHex, cx "200", cy "200", r "200" ] [] ]
    , g [] [ path [ transform "scale(0.1)", fill whiteHex, d twitterPoints ] [] ]
    ]
  ]

github : Coordinates -> Svg Msg
github coordinates =
  a [ class "social-icon", href "https://github.com/ryanbahniuk", target "_blank" ]
  [ svg [ x (toString coordinates.x), y (toString coordinates.y) ]
    [ g [] [ circle [ transform "scale(0.1)", fill whiteHex, cx "200", cy "200", r "200" ] [] ]
    , g [] [ path [ d githubPoints, stroke "none", fill lightGreyHex, fillRule "evenodd" ] [] ]
    ]
  ]

href : String -> Attribute msg
href =
  attribute "href"

twitterPoints : String
twitterPoints =
  "M163.4,305.5c88.7,0,137.2-73.5,137.2-137.2c0-2.1,0-4.2-0.1-6.2c9.4-6.8,17.6-15.3,24.1-25c-8.6,3.8-17.9,6.4-27.7,7.6c10-6,17.6-15.4,21.2-26.7c-9.3,5.5-19.6,9.5-30.6,11.7c-8.8-9.4-21.3-15.2-35.2-15.2c-26.6,0-48.2,21.6-48.2,48.2c0,3.8,0.4,7.5,1.3,11c-40.1-2-75.6-21.2-99.4-50.4c-4.1,7.1-6.5,15.4-6.5,24.2c0,16.7,8.5,31.5,21.5,40.1c-7.9-0.2-15.3-2.4-21.8-6c0,0.2,0,0.4,0,0.6c0,23.4,16.6,42.8,38.7,47.3c-4,1.1-8.3,1.7-12.7,1.7c-3.1,0-6.1-0.3-9.1-0.9c6.1,19.2,23.9,33.1,45,33.5c-16.5,12.9-37.3,20.6-59.9,20.6c-3.9,0-7.7-0.2-11.5-0.7C110.8,297.5,136.2,305.5,163.4,305.5"

githubPoints : String
githubPoints =
  "M19.9981583,0 C8.95546211,0 0,8.95423432 0,20.0006139 C0,28.8369809 5.73007152,36.3326069 13.6775223,38.9772553 C14.6781669,39.161423 15.042819,38.5438473 15.042819,38.0134442 C15.042819,37.5395193 15.02563,36.2810399 15.0158077,34.6124804 C9.45271494,35.8206206 8.2789527,31.9309985 8.2789527,31.9309985 C7.36916419,29.6203076 6.05789005,29.0051874 6.05789005,29.0051874 C4.24199638,27.7651248 6.19540195,27.7896805 6.19540195,27.7896805 C8.20283004,27.9308757 9.25872495,29.8511311 9.25872495,29.8511311 C11.0426962,32.9070874 13.9402683,32.0243101 15.0796525,31.5123239 C15.2613647,30.2206943 15.7782621,29.3391448 16.349182,28.8394364 C11.9082845,28.3348169 7.239019,26.6183738 7.239019,18.9545413 C7.239019,16.7715399 8.01866233,14.9851131 9.29801406,13.587894 C9.09174622,13.0820467 8.40541453,11.0476074 9.49445962,8.2949139 C9.49445962,8.2949139 11.1728414,7.75714417 14.9937076,10.3453145 C16.5886,9.90085638 18.300132,9.67985512 20.0006139,9.67126063 C21.699868,9.67985512 23.4101722,9.90085638 25.0075202,10.3453145 C28.8259308,7.75714417 30.501857,8.2949139 30.501857,8.2949139 C31.5933577,11.0476074 30.907026,13.0820467 30.7019859,13.587894 C31.9837932,14.9851131 32.7572976,16.7715399 32.7572976,18.9545413 C32.7572976,26.6380184 28.0806655,28.328678 23.6262623,28.8234752 C24.3432886,29.441051 24.9829645,30.661469 24.9829645,32.5277019 C24.9829645,35.2005893 24.9584088,37.3578072 24.9584088,38.0134442 C24.9584088,38.5487584 25.3193775,39.1712453 26.3335277,38.9760275 C34.2748396,36.3252402 40,28.8345253 40,20.0006139 C40,8.95423432 31.0445379,0 19.9981583,0"

maskText : Svg Msg
maskText =
  Svg.mask [ id "knockout-text" ]
  [ rect [ width "100%", height "100%",  fill whiteHex, x "0", y "0" ] []
  , text_ [ class "intro", x "50%", y "300", fill blackHex, textAnchor "middle" ] [ text introTextFirstLine ]
  , text_ [ class "intro", x "50%", y "350", fill blackHex, textAnchor "middle" ] [ text introTextSecondLine ]
  , text_ [ class "intro", x "50%", y "400", fill blackHex, textAnchor "middle" ] [ text introTextThirdLine ]
  , text_ [ class "intro", x "50%", y "450", fill blackHex, textAnchor "middle" ] [ text introTextFourthLine ]
  , text_ [ class "credit", x "50%", y "800", fill blackHex, textAnchor "middle" ] [ text creditLine ]
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

withinRangeX : Int -> Cursor -> Coordinates -> Bool
withinRangeX range cursor coordinates =
  ((cursor.coordinates.x - coordinates.x <= range) && (cursor.coordinates.x - coordinates.x >= 0)) || ((coordinates.x - cursor.coordinates.x <= range) && (coordinates.x - cursor.coordinates.x >= 0))

withinRangeY : Int -> Cursor -> Coordinates -> Bool
withinRangeY range cursor coordinates =
  ((cursor.coordinates.y - coordinates.y <= range) && (cursor.coordinates.y - coordinates.y >= 0)) || ((coordinates.y - cursor.coordinates.y <= range) && (coordinates.y - cursor.coordinates.y >= 0))

withinRange : Int -> Cursor -> Coordinates -> Bool
withinRange range cursor coordinates =
  (withinRangeX range cursor coordinates) && (withinRangeY range cursor coordinates)

withinRangeVertex : Model -> Bool
withinRangeVertex model =
  any (withinRange 10 model.cursor) (map (\x -> x.coordinates) (flattenVertices model.polygons))

withinRangeSocial : Model -> Bool
withinRangeSocial model =
  (withinRange 40 model.cursor model.twitterCoordinates) || (withinRange 40 model.cursor model.githubCoordinates)

shouldHideCursor : Model -> Bool
shouldHideCursor model =
  (withinRangeVertex model) || (withinRangeSocial model)

maybeCursorView : Model -> Svg Msg
maybeCursorView model =
  if (shouldHideCursor model) then
    text ""
  else
    cursorView model.cursor

cursorView : Cursor -> Svg Msg
cursorView cursor =
  g []
  [ circle [ cx (toString cursor.coordinates.x), cy (toString cursor.coordinates.y), r "10", class "cursor-third-circle" ] []
  , circle [ cx (toString cursor.coordinates.x), cy (toString cursor.coordinates.y), r "10", class "cursor-second-circle" ] []
  , circle [ cx (toString cursor.coordinates.x), cy (toString cursor.coordinates.y), r "10", class "cursor-circle" ] []
  ]

clickAction : Model -> Svg.Attribute Msg
clickAction model =
  if (withinRangeSocial model) then
    onStopPropClick Noop
  else if (noneInFlight model.polygons) then
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
