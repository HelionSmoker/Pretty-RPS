import
  algorithm, #  reversed()
  os, #         commandLineParams(), paramStr
  strutils, #   parseInt()
  random, #     randomize(), rand()
  terminal #    getch(), eraseScreen()

proc catPad(a1, a2: array[14, seq[int]]): array[14, seq[int]] =
  # The palm is the same for all states, so we just concatenate and pad
  # the elements to 21 (max row length)
  for i in 0..13:
    result[i] = a1[i] & a2[i] & newSeq[int](21 - len(a1[i]) - len(a2[i]))

proc invert(a: array[14, seq[int]]): array[14, seq[int]] =
  for i in 0..13: result[i] = reversed(a[i])

const
  PALM = [
    @[0, 0, 0, 3, 1, 1, 1, 1, 1],
    @[0, 0, 3, 1, 2, 2, 2, 2, 2, 1, 1, 1],
    @[0, 3, 1, 2, 2, 2, 2, 2, 2, 1, 2, 2, 2],
    @[1, 1, 2, 2, 2, 2, 1, 2, 2, 1, 2, 2, 2],
    @[2, 2, 2, 2, 2, 2, 1, 2, 2, 1],
    @[2, 2, 2, 2, 2, 2, 1, 2, 2, 1, 2, 2, 2],
    @[2, 2, 2, 2, 2, 2, 1, 2, 2, 1, 2, 2, 2],
    @[2, 2, 2, 2, 2, 2, 2, 1, 1, 1],
    @[2, 2, 2, 2, 2, 2, 2],
    @[2, 2, 2, 2, 2, 2, 2],
    @[2, 2, 2, 2, 2, 2, 2],
    @[1, 1, 2, 2, 2, 2, 2],
    @[0, 3, 1, 1, 2, 2, 2],
    @[0, 0, 0, 3, 1, 1, 1, 1, 1, 1, 1, 1]]
  ROCK = catPad(PALM, [
    @[3],
    @[1, 3],
    @[1, 3],
    @[1, 3],
    @[1, 1, 1, 3],
    @[1, 3],
    @[1, 3],
    @[1, 1, 1, 3],
    @[1, 2, 2, 2, 2, 2, 1, 3],
    @[1, 2, 2, 2, 2, 2, 1, 3],
    @[2, 1, 1, 1, 1, 1, 3],
    @[1, 2, 2, 2, 2, 1, 3],
    @[1, 2, 2, 2, 2, 1, 3],
    @[3]])
  PAPER = catPad(PALM, [
    @[3],
    @[1, 1, 1, 1, 1, 3],
    @[2, 2, 2, 2, 1, 3],
    @[2, 2, 2, 2, 1, 3],
    @[2, 1, 1, 1, 1, 1, 1, 1, 3],
    @[2, 2, 2, 2, 2, 1, 3],
    @[2, 2, 2, 2, 2, 1, 3],
    @[2, 1, 1, 1, 1, 1, 1, 1, 3],
    @[2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3],
    @[2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 1, 3],
    @[2, 2, 2, 2, 1, 1, 1, 1, 1, 1, 3],
    @[2, 2, 2, 2, 2, 2, 2, 2, 1, 3],
    @[2, 2, 2, 2, 2, 2, 2, 2, 1, 3],
    @[1, 1, 1, 3]])
  SCISSORS = catPad(PALM, [
    @[3, 0, 0, 1, 1, 1, 1, 1, 1, 3],
    @[2, 2, 2, 2, 2, 2, 1, 3],
    @[2, 2, 2, 2, 2, 1, 3],
    @[2, 1, 1, 1, 1, 3],
    @[2, 2, 1, 1, 3],
    @[2, 1, 1, 1, 3],
    @[2, 2, 2, 2, 1, 1, 3],
    @[1, 1, 1, 1, 2, 2, 2, 2, 2, 1, 3],
    @[1, 2, 2, 2, 2, 2, 1, 1, 1, 1, 2, 2, 1, 3],
    @[1, 2, 2, 2, 2, 2, 1, 3, 0, 0, 1, 1, 3],
    @[2, 1, 1, 1, 1, 1, 3],
    @[1, 2, 2, 2, 2, 1, 3],
    @[1, 2, 2, 2, 2, 1, 3],
    @[3]])
  STATES = [
    ROCK, PAPER, SCISSORS,
    invert(ROCK), invert(PAPER), invert(SCISSORS)]
  MOVES = ['r', 'p', 's']

let
  MODE = block: # Supported: 'wins' and 'points'.
    var mode = "wins"
    var i = find(commandLineParams(), ("-m"))
    if i != -1: mode = paramStr(i+2)
    mode
  GOAL = block: # Mode dependant.
    var goal = 3
    var i = find(commandLineParams(), ("-g"))
    if i != -1: goal = parseInt(paramStr(i+2))
    goal

var
  visuals = newStringOfCap(2000)
  style = [
    "",            # Blank
    "[48;5;235m", # Outline (black)
    "",            # Skin color (random)
    "[0m"]        # Reset style
  move, counter: Natural
  score = [0, 0]
  choice: char

proc compileColors(list: seq[int]) =
  for col in list:
    visuals.add(style[col])
    visuals.add("   ")

randomize()
proc catVisuals(move, counter: Natural) =
  visuals = ""
  style[2] = "[4" & $rand(1..7) & 'm'

  for i in 0..13:
    compileColors(STATES[move][i])
    compileColors(STATES[counter][i])
    visuals.add("[0m\n")

while score[0] != GOAL and score[1] != GOAL:
  catVisuals(0, 3) # Fist is default state

  for i in 0..6: # Shake fist 3 times.
    eraseScreen()
    echo visuals
    if i mod 2 != 0: echo "\n\n\n"
    sleep 200

  stdout.write("Enter your choice (r, p, s): ")
  choice = getch() # Accept only one char.

  if choice == 'q': quit 0
  for i in 0..high(MOVES):
    if MOVES[i] == choice: move = i

  counter = rand(2)
  case move - counter
  of -2, 1: inc(score[0])
  of -1, 2: inc(score[1])
  else: discard # Draw

  eraseScreen()
  catVisuals(move, counter + 3)
  echo '\n', visuals, center($score[0] & " - " & $score[1], 122)
  sleep 2000

if score[0] == 3:
  echo "You know, I mean, you beat the system! I mean, you're an icon, man!".center(122)
else:
  echo "As usual, the forces of darkness have triumphed over good.".center(122)
