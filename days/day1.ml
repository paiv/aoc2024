#!/usr/bin/env ocamlrun ocaml str.cma

module Day1 =
  struct
    let parse text =
      let parse_pair s =
        Str.split (Str.regexp " +") (String.trim s)
        |> List.map int_of_string in
      String.split_on_char '\n' (String.trim text)
      |> List.map parse_pair
      |> List.map (function [a; b] -> (a, b) | _ -> raise (Failure "err"))
      |> List.split
    ;;

    let part1 text =
      let (a, b) = parse text in
      let diff r a b = r + abs (a - b) in
      let a = List.sort Int.compare a in
      let b = List.sort Int.compare b in
      List.fold_left2 diff 0 a b
    ;;

    let count x =
      List.fold_left (fun r h -> if h = x then r + 1 else r) 0
    ;;

    let part2 text =
      let (a, b) = parse text in
      let diff r a = r + (a * count a b) in
      List.fold_left diff 0 a
    ;;

  end;;


let data = {|
3   4
4   3
2   5
1   3
3   9
3   3
    |} in
  data
  |> Day1.part1
  |> fun ans -> assert (ans = 11)
  ;
  data
  |> Day1.part2
  |> fun ans -> assert (ans = 31)
  ;;


let read_text = fun fn ->
  let fd = open_in_bin fn in
  let n = in_channel_length fd in
    really_input_string fd n
  ;;


let () =
  let data = read_text "day1.in" in
    data
    |> Day1.part1
    |> Printf.printf "part1: %d\n"
    ;
    data
    |> Day1.part2
    |> Printf.printf "part2: %d\n"
  ;;
