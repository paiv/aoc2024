#!/usr/bin/env elixir

defmodule Day11 do
  defp evolve(stones, 0) do
    stones
  end

  defp evolve(stones, rounds) do
    state =
      stones
      |> Stream.flat_map(&split_stone/1)
      |> Enum.reduce(%{}, fn {k, v}, acc ->
        Map.update(acc, k, v, &(&1 + v))
      end)

    evolve(state, rounds - 1)
  end

  defp split_stone({0, n}) do
    [{1, n}]
  end

  defp split_stone({x, n}) do
    s = to_string(x)
    t = String.length(s)

    if rem(t, 2) == 0 do
      t = div(t, 2)

      0..1
      |> Enum.map(&String.slice(s, &1 * t, t))
      |> Enum.map(&String.to_integer/1)
      |> Enum.map(&{&1, n})
    else
      [{x * 2024, n}]
    end
  end

  def part1(data, rounds \\ 25) do
    stones =
      String.split(data)
      |> Enum.map(&String.to_integer/1)
      |> Enum.reduce(%{}, &Map.put(&2, &1, 1))

    evolve(stones, rounds)
    |> Enum.reduce(0, &(&2 + elem(&1, 1)))
  end

  def part2(data) do
    part1(data, 75)
  end
end

data = """
125 17
"""

case Day11.part1(data), do: (55312 -> true)

data = File.read!("day11.in")
ans = Day11.part1(data)
IO.puts("part1: #{ans}")
ans = Day11.part2(data)
IO.puts("part2: #{ans}")
