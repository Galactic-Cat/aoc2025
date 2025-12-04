import gleam/int
import gleam/list
import grid.{type Grid}

pub type Z {
  Roll
  Floor
}

type Either(a, b) {
  Left(a)
  Right(b)
}

pub fn solve(g: Grid(Z)) -> #(Int, Int) {
  #(first(remove_rolls(g)), repeat_remove_rolls(g, 0))
}

fn count_neighbours(g: Grid(Z), x: Int, y: Int) -> Either(Int, Nil) {
  case grid.get(g, x, y) {
    Ok(Roll) ->
      Left(
        int.sum(
          list.map(
            [
              #(x - 1, y - 1),
              #(x, y - 1),
              #(x + 1, y - 1),
              #(x + 1, y),
              #(x + 1, y + 1),
              #(x, y + 1),
              #(x - 1, y + 1),
              #(x - 1, y),
            ],
            fn(address) {
              let #(nx, ny) = address

              case grid.get(g, nx, ny) {
                Ok(Roll) -> 1
                Ok(Floor) -> 0
                Error(_) -> 0
              }
            },
          ),
        ),
      )
    Ok(Floor) -> Right(Nil)
    Error(_) -> panic as { "Tried to get out of bounds position" }
  }
}

fn first(x: #(a, b)) -> a {
  let #(a, _b) = x
  a
}

fn remove_rolls(g: Grid(Z)) -> #(Int, Grid(Z)) {
  let cg = grid.map_coordinates(g, count_neighbours)

  #(
    grid.reduce(
      cg,
      fn(x, acc) {
        case x {
          Left(n) ->
            case n < 4 {
              True -> acc + 1
              False -> acc
            }
          Right(_) -> acc
        }
      },
      0,
    ),
    grid.map(cg, fn(x) {
      case x {
        Left(n) -> {
          case n < 4 {
            True -> Floor
            False -> Roll
          }
        }
        Right(_) -> Floor
      }
    }),
  )
}

fn repeat_remove_rolls(g: Grid(Z), acc: Int) -> Int {
  case remove_rolls(g) {
    #(0, _ng) -> acc
    #(c, ng) -> repeat_remove_rolls(ng, acc + c)
  }
}
