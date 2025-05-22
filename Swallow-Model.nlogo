breed [short-swallows short-swallow]
breed [long-swallows long-swallow]
breed [cars car]

short-swallows-own [delay]
long-swallows-own [delay]
cars-own [delay]

globals [
  short-deaths
  long-deaths
]

to setup
  clear-all
  reset-ticks
  set short-deaths 0
  set long-deaths 0

  create-short-swallows 25 [
    setxy random-xcor min-pycor
    set shape "butterfly"
    set color blue
    set heading 0
    set delay random 20
  ]

  create-long-swallows 25 [
    setxy random-xcor min-pycor
    set shape "butterfly"
    set color red
    set heading 0
    set delay random 70 + 20
  ]

  create-cars car-count [
    setxy random-xcor max-pycor
    set shape "car top"
    set size 2
    set color gray
    set heading 180
    set delay random 30
  ]

  setup-plots
end

to go
  move-short-swallows
  move-long-swallows
  move-cars
  check-collisions
  spawn-new-swallows
  maintain-car-count
  update-death-plot
  tick
end

to move-short-swallows
  ask short-swallows [
    ifelse delay > 0 [
      set delay delay - 1
    ] [
      set heading 0
      let nearby-car one-of cars in-radius 3
      if nearby-car != nobody [
        let left-clear? not any? cars in-radius 2 with [ xcor < [xcor] of myself ]
        let right-clear? not any? cars in-radius 2 with [ xcor > [xcor] of myself ]

        if left-clear? and not right-clear? [
          set xcor xcor - 0.3
        ]

        if right-clear? and not left-clear? [
          set xcor xcor + 0.3
        ]

        ifelse left-clear? and right-clear? [
          ifelse (max-pxcor - xcor) > (xcor - min-pxcor) [
            set xcor xcor + 0.3
          ] [
            set xcor xcor - 0.3
          ]
        ] [
          if not left-clear? and not right-clear? [
            ifelse random-float 1.0 < 0.5 [
              set xcor xcor + 0.1
            ] [
              set xcor xcor - 0.1
            ]
          ]
        ]
      ]
      forward 0.15
      if ycor >= max-pycor [
        setxy random-xcor min-pycor
        set delay random 20
      ]
      if xcor > max-pxcor [ set xcor max-pxcor ]
      if xcor < min-pxcor [ set xcor min-pxcor ]
    ]
  ]
end

to move-long-swallows
  ask long-swallows [
    ifelse delay > 0 [
      set delay delay - 1
    ] [
      set heading 0
      let nearby-car one-of cars in-radius 2
      if nearby-car != nobody [
        ifelse random 2 = 0 [
          set xcor xcor + 0.2
        ] [
          set xcor xcor - 0.2
        ]
      ]
      forward 0.12
      if ycor >= max-pycor [
        setxy random-xcor min-pycor
        set delay random 70 + 20
      ]
      if xcor > max-pxcor [ set xcor max-pxcor ]
      if xcor < min-pxcor [ set xcor min-pxcor ]
    ]
  ]
end

to move-cars
  ask cars [
    ifelse delay > 0 [
      set delay delay - 1
    ] [
      forward 0.2
      if ycor <= min-pycor [
        setxy random-xcor max-pycor
        set delay random 30
      ]
    ]
  ]
end

to check-collisions
  ask short-swallows [
    if any? cars in-radius 1 [
      set short-deaths short-deaths + 1
      die
    ]
  ]
  ask long-swallows [
    if any? cars in-radius 1 [
      set long-deaths long-deaths + 1
      die
    ]
  ]
end

to spawn-new-swallows
  if count short-swallows < 25 [
    create-short-swallows 1 [
      setxy random-xcor min-pycor
      set shape "butterfly"
      set color blue
      set heading 0
      set delay random 20
    ]
  ]
  if count long-swallows < 25 [
    create-long-swallows 1 [
      setxy random-xcor min-pycor
      set shape "butterfly"
      set color red
      set heading 0
      set delay random 70 + 20
    ]
  ]
end

to maintain-car-count
  let car-diff car-count - count cars
  if car-diff > 0 [
    create-cars car-diff [
      setxy random-xcor max-pycor
      set shape "car top"
      set size 2
      set color gray
      set heading 180
      set delay random 30
    ]
  ]
  if car-diff < 0 [
    ask n-of (- car-diff) cars [
      die
    ]
  ]
end

to update-death-plot
  set-current-plot "Swallow Deaths"
  set-current-plot-pen "Short deaths"
  plotxy ticks short-deaths
  set-current-plot-pen "Long deaths"
  plotxy ticks long-deaths
end



;; SETUP-PLOTS must have been defined in your model already; just show the deaths
;; reporters for the two monitors should be:
;;   short-deaths
;;   long-deaths

;; UPDATE-PLOTS is a primitive that you already have; make sure its pens are:
;;   "Short wing deaths" plotting short-deaths
;;   "Long wing deaths"  plotting long-deaths
@#$#@#$#@
GRAPHICS-WINDOW
210
10
647
448
-1
-1
13
1
10
1
1
1
0
1
1
1
-16
16
-16
16
0
0
1
ticks
30

BUTTON
25
34
91
67
NIL
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
106
34
169
67
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
6
312
206
462
Swallow Deaths
Time
Number of Swallows
0
10
0
10
true
false
"" ""
PENS
"Short deaths" 1 0 -14070903 true "" ""
"Long deaths" 1 0 -2674135 true "" ""

MONITOR
21
76
177
121
Short Wingspan Deaths
short-deaths
17
1
11

MONITOR
24
132
178
177
Long Wingspan Deaths
long-deaths
17
1
11

SLIDER
21
216
193
249
car-count
car-count
0
60
24
1
1
NIL
HORIZONTAL

TEXTBOX
31
268
181
296
Red 
11
14
1

TEXTBOX
55
267
205
285
= Long Wingspan Swallows
11
0
1

TEXTBOX
32
292
182
310
Blue
11
104
1

TEXTBOX
56
292
206
310
= Short Wingspan Swallows
11
0
1

TEXTBOX
26
194
212
222
Adjust the amount of cars here!
11
0
1
@#$#@#$#@
## WHAT IS IT?

This model simulates how two types of swallows — short-winged and long-winged — navigate through traffic made up of moving cars. It demonstrates how physical traits (like wing length) can affect the swallows' ability to avoid danger and survive. The simulation can be used to explore the concept of natural selection, especially how maneuverability impacts survival rates in different environments.

## HOW IT WORKS

The model has 2 different types of swallows:

- Short-winged swallows are more agile and try to avoid cars using directional movement based on nearby obstacles.

- Long-winged swallows are less agile and use a simpler, more random strategy to avoid cars.

Swallows start at the bottom and move upward, trying to cross the screen.

Cars start from the top and move downward.

When a swallow collides with a car, it dies and a new one is spawned to keep population sizes constant.

The number of cars on screen is always adjusted to match the car-count sliderl.

## HOW TO USE IT

1.Sliders:

car-count: Adjusts the number of cars in the simulation. The model keeps the number of cars equal to the value adjusted on the slider throughout the simulation.

2.Buttons:

setup: Initializes the model, placing 25 short-winged, 25 long-winged swallos, and the number of cars set by the car-count slider.

go: Runs the simulation. Swallos and cars begin to move and interact.

3.Plots:

Swallow Deaths: Displays the cumulative number of deaths for both short-winged and long-winged swallows over time. 

## THINGS TO NOTICE

- Which type of swallows survive more often?

- How does the number of cars affect the death rate of both short-winged and long-winged swallows?

- Do short-winged swallows successfully avoid more collisions compared to long-winged swallows?

- How does the difference in maneuvering behaviour impact the overall survival?

## THINGS TO TRY

- Increase or decrease the car-count slider and observe how each type of swallow is affected.

- Try running the simulation multiple times to see if one type consistently survives more.

- Observe the plot over time and compare the rate of deaths for both swallow types.


@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

car top
true
0
Polygon -7500403 true true 151 8 119 10 98 25 86 48 82 225 90 270 105 289 150 294 195 291 210 270 219 225 214 47 201 24 181 11
Polygon -16777216 true false 210 195 195 210 195 135 210 105
Polygon -16777216 true false 105 255 120 270 180 270 195 255 195 225 105 225
Polygon -16777216 true false 90 195 105 210 105 135 90 105
Polygon -1 true false 205 29 180 30 181 11
Line -7500403 false 210 165 195 165
Line -7500403 false 90 165 105 165
Polygon -16777216 true false 121 135 180 134 204 97 182 89 153 85 120 89 98 97
Line -16777216 false 210 90 195 30
Line -16777216 false 90 90 105 30
Polygon -1 true false 95 29 120 30 119 11

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.2.2
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0
-0.2 0 0 1
0 1 1 0
0.2 0 0 1
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@

@#$#@#$#@
