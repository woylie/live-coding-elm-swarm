# Live Coding: Swarm Behaviour in Elm

Result of a live coding session in Elm implementing basic swarm behaviour.

## How to run

1. Make sure you have Elm installed ([https://guide.elm-lang.org/install.html](https://guide.elm-lang.org/install.html)).
2. Clone repo, cd into directory and run `elm-package install`.
3. Run `elm-reactor`.
4. Open `localhost:8000` in browser, select `Main.elm`.

## Adjustments

You can get bigger and more stable swarms by using the nth closest neighbor for the min/max distance calculations. If you want to experiment, change line 121 to `|> List.drop 3` (or 5, or 10). Also increase minDistance and maxDistance in lines 22 and 27.
