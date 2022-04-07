import
  os, #         commandLineParams(), paramStr()
  random, #     randomize(), rand(), sample()
  strutils, #   parseInt(), center()
  algorithm, #  reversed()
  terminal #    getch(), eraseScreen()

proc getParamOrDef(default, param: string): string =
  result = default
  var i = commandLineParams().find(param)
  if i != -1: result = paramStr(i+2)

randomize()
let
  STYLE = [
    "",                                            # Blank
    "[48;5;235m",                                 # Outline (black)
    "[4" & $rand(1..7) & 'm',                     # Skin color (random)
    "[0m"]                                        # Reset style
  MODE = getParamOrDef("wins", "-m")               # Supported: 'wins' and 'points'.
  GOAL = getParamOrDef("3", "-g").parseInt()       # Mode dependant.

const
  HEIGHT = 14
  WIDTH = 21
  MOVES = ['q', 'r', 'p', 's']
  PROMT = "Enter your choice " & $MOVES & ": "
  END_MSG = [
    @[
      "You know, I mean, you beat the system! I mean, you're an icon, man!"],
    @[
      "As usual, the forces of darkness have triumphed over good.",
      "You were almost a Jill sandwich!",
      "Ain’t nothing fair."]]
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

type
  PixelMap = array[HEIGHT, seq[int]]
  ArtStr = array[HEIGHT, string]

proc catPad(a: PixelMap): PixelMap =
  # The palm is the same for all states, so we just concatenate and pad
  # the elements to 21 (max row length)c
  for i in 0..13:
    result[i] = PALM[i] & a[i] & newSeq[int](21 - len(PALM[i]) - len(a[i]))

proc invert(a: PixelMap): PixelMap =
  for i in 0..13: result[i] = reversed(a[i])

const
  ROCK = catPad([
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
  PAPER = catPad([
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
  SCISSORS = catPad([
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

proc toStr(a: PixelMap): ArtStr =
  for i in 0..HEIGHT - 1:
    for col in a[i]:
      result[i].add(STYLE[col] & "   ")
    result[i].add("[0m")

let STATES = [
  toStr ROCK, toStr PAPER, toStr SCISSORS,
  invert(ROCK).toStr(), invert(PAPER).toStr(), invert(SCISSORS).toStr()]

var
  visuals = newStringOfCap(2000)
  move, counter: Natural
  score = [0, 0]

proc catArt(move, counter: int) =
  visuals = ""
  for i in 0..13:
    visuals.add(STATES[move][i])
    visuals.add(STATES[counter][i])
    visuals.add("[0m\n")

while score[0] != GOAL and score[1] != GOAL:
  catArt(0, 3) # Fist is default state

  for i in 0..6: # Shake fist 3 times.
    eraseScreen()
    echo visuals
    if i mod 2 != 0: echo "\n\n\n"
    sleep 180

  stdout.write(PROMT)
  move = MOVES.find(getch()) # find() - Return pos, getch() - Accept one char.
  if move == 0 or move == -1: quit 0

  counter = rand(2)
  case move - counter - 1
  of -2, 1:
    if MODE == "points": dec(score[1])
    inc(score[0])
  of -1, 2:
    if MODE == "points": dec(score[0])
    inc(score[1])
  else: discard # Draw

  catArt(move - 1, counter + 3)
  eraseScreen()
  echo '\n', visuals, center($score[0] & " - " & $score[1], WIDTH * 6)
  sleep 1800

if score[0] == GOAL: echo END_MSG[0].sample().center(WIDTH * 6)
else: echo END_MSG[1].sample().center(WIDTH * 6)
