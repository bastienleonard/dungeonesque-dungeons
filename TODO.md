* Use the conventional parameters order in `map`, `filter`, etc.
* Put vegetation in lower levels
* Override the default error screen
* Make the amount of stairs and shelves random
* We show the content of `EXPLORED-OUT-OF-SIGHT` tiles. This is not a
  problem right now because it's rare to leave units out of sight.
* Macro for exhaustive `match`
* Investigate this: `local enemies_count = math.max(1, math.floor((bound_map.width * bound_map.height * 0.0050000000000000001)))`
* Generate maps of varying sizes
* Remove usages of `local` as much as possible
* Document building the project (especially how to use Fennel)
* Handle window resizing
