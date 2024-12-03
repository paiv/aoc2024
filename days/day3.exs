#!/usr/bin/env elixir

defmodule Day3 do
  def part1(data) do
    rx = ~r/mul\((\d+),(\d+)\)/

    for [_, x, y] <- Regex.scan(rx, data) do
      String.to_integer(x) * String.to_integer(y)
    end
    |> Enum.sum()
  end

  def part2(data) do
    rx = ~r/do\(\)|mul\((-?\d+),(-?\d+)\)|don't\(\)/

    for [x, y] <- Regex.scan(rx, data) |> filt(true) do
      String.to_integer(x) * String.to_integer(y)
    end
    |> Enum.sum()
  end

  defp filt([], _t) do
    []
  end

  defp filt([[m] | tail], _) do
    case String.slice(m, 0..2) do
      "don" -> filt(tail, false)
      "do(" -> filt(tail, true)
    end
  end

  defp filt([[_, x, y] | tail], true) do
    [[x, y] | filt(tail, true)]
  end

  defp filt([_ | tail], false) do
    filt(tail, false)
  end
end

data = """
xmul(2,4)%&mul[3,7]!@^do_not_mul(5,5)+mul(32,64]then(mul(11,8)mul(8,5))
"""

case Day3.part1(data), do: (161 -> true)

data = """
xmul(2,4)&mul[3,7]!^don't()_mul(5,5)+mul(32,64](mul(11,8)undo()?mul(8,5))
"""

case Day3.part2(data), do: (48 -> true)

data = File.read!("day3.in")
ans = Day3.part1(data)
IO.puts("part1: #{ans}")
ans = Day3.part2(data)
IO.puts("part2: #{ans}")
