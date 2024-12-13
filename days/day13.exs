#!/usr/bin/env elixir

defmodule Day13 do
  defp parse_data(data) do
    for [x] <- Regex.scan(~r/[+-]?\d+/, data) do
      String.to_integer(x)
    end
    |> Enum.chunk_every(6)
  end

  def part1(data, n \\ 0) do
    for [ax, ay, bx, by, px, py] <- parse_data(data) do
      un = (px + n) * ay - (py + n) * ax
      ud = ay * bx - ax * by
      u = div(un, ud)
      vn = px + n - bx * u

      if rem(un, ud) == 0 and rem(vn, ax) == 0 do
        u + 3 * div(vn, ax)
      else
        0
      end
    end
    |> Enum.sum()
  end

  def part2(data) do
    part1(data, 10_000_000_000_000)
  end
end

data = """
Button A: X+94, Y+34
Button B: X+22, Y+67
Prize: X=8400, Y=5400

Button A: X+26, Y+66
Button B: X+67, Y+21
Prize: X=12748, Y=12176

Button A: X+17, Y+86
Button B: X+84, Y+37
Prize: X=7870, Y=6450

Button A: X+69, Y+23
Button B: X+27, Y+71
Prize: X=18641, Y=10279
"""

case Day13.part1(data), do: (480 -> true)

data = File.read!("day13.in")
ans = Day13.part1(data)
IO.puts("part1: #{ans}")
ans = Day13.part2(data)
IO.puts("part2: #{ans}")
