import gleam/dict.{type Dict}
import gleam/float
import gleam/int
import gleam/io
import gleam/list
import gleam/set.{type Set}

import alist.{type AList}
import olist.{type OList}

fn debug(value: x, message: String) -> x {
  io.println(message)
  value
}

pub type Coordinate =
  #(Int, Int, Int)

pub fn solve(coordinates: List(Coordinate)) -> #(Int, Nil) {
  let a_coordinates = alist.from_list(coordinates)
  let distances =
    alist.map_index(a_coordinates, fn(index, a) {
      distance_from(a, alist.drop(a_coordinates, index))
    })
    |> debug("1")
    |> alist.map_index(fn(index, a) {
      alist.map_index(a, fn(offset, b) { #(b, #(index, index + offset + 1)) })
    })
    |> debug("2")
    // |> alist.reduce(alist.combine, alist.new())
    |> alist.to_list()
    |> debug("3")
    |> list.map(fn(l) {
      list.map(dict.to_list(l), fn(x) {
        let #(_, a) = x
        a
      })
    })
    |> debug("4")
    |> list.flatten()
    |> debug("5")
    |> olist.create()

  echo "Calculated distances"

  let clusters =
    find_clusters(distances, dict.new(), 1000, 0)
    |> to_clusters()

  #(cluster_sizes(clusters) |> list.take(3) |> int.product, Nil)
}

fn distance(a: Coordinate, b: Coordinate) -> Float {
  let #(ax, ay, az) = a
  let #(bx, by, bz) = b

  let assert Ok(dx) = float.power(int.to_float(bx - ax), 2.0)
  let assert Ok(dy) = float.power(int.to_float(by - ay), 2.0)
  let assert Ok(dz) = float.power(int.to_float(bz - az), 2.0)

  let assert Ok(result) = float.square_root(dx +. dy +. dz)

  result
}

fn distance_from(a: Coordinate, others: AList(Coordinate)) -> AList(Float) {
  alist.map(others, fn(b) { distance(a, b) })
}

fn combine_clusters(clusters: Dict(Int, Int), a: Int, b: Int) -> Dict(Int, Int) {
  case a == b {
    True -> clusters
    False ->
      dict.map_values(clusters, fn(_key, c) {
        case c == b {
          True -> a
          False -> c
        }
      })
  }
}

fn find_clusters(
  distances: OList(#(Int, Int)),
  clusters: Dict(Int, Int),
  limit: Int,
  index: Int,
) -> Dict(Int, Int) {
  case index >= limit, olist.at(distances, index) {
    True, _ -> clusters
    _, Ok(#(a, b)) ->
      case dict.get(clusters, a), dict.get(clusters, b) {
        Ok(ac), Ok(bc) ->
          find_clusters(
            distances,
            combine_clusters(clusters, ac, bc),
            limit,
            index + 1,
          )
        Ok(ac), Error(_) ->
          find_clusters(
            distances,
            dict.insert(clusters, b, ac),
            limit,
            index + 1,
          )
        Error(_), Ok(bc) ->
          find_clusters(
            distances,
            dict.insert(clusters, a, bc),
            limit,
            index + 1,
          )
        Error(_), Error(_) ->
          find_clusters(
            distances,
            dict.insert(clusters, a, index) |> dict.insert(b, index),
            limit,
            index + 1,
          )
      }
    _, Error(_) -> clusters
  }
}

fn to_clusters(input: Dict(Int, Int)) -> Dict(Int, Set(Int)) {
  dict.to_list(input)
  |> to_clusters_helper()
}

fn to_clusters_helper(input: List(#(Int, Int))) -> Dict(Int, Set(Int)) {
  case list.first(input) {
    Ok(#(i, c)) -> {
      let clusters = to_clusters_helper(list.drop(input, 1))

      case dict.get(clusters, c) {
        Ok(cluster) -> dict.insert(clusters, c, set.insert(cluster, i))
        Error(_) -> dict.insert(clusters, c, set.from_list([i]))
      }
    }
    Error(_) -> dict.new()
  }
}

fn cluster_sizes(clusters: Dict(Int, Set(Int))) -> List(Int) {
  dict.to_list(clusters)
  |> list.map(fn(x) {
    let #(_, s) = x
    set.size(s)
  })
  |> list.sort(int.compare)
  |> list.reverse()
}
