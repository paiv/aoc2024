#!/usr/bin/env elixir

defmodule Day1 do
  defp parse(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(fn s -> String.split(s) |> Enum.map(&String.to_integer/1) |> List.to_tuple() end)
    |> Enum.unzip()
  end

  def part1(data) do
    {a, b} = parse(data)

    Enum.zip_reduce([Enum.sort(a), Enum.sort(b)], 0, fn [x, y], acc ->
      acc + abs(x - y)
    end)
  end

  def part2(data) do
    {a, b} = parse(data)

    Enum.reduce(a, 0, fn x, acc ->
      acc + x * Enum.count(b, &(&1 == x))
    end)
  end
end

data = """
3   4
4   3
2   5
1   3
3   9
3   3
"""

case Day1.part1(data), do: (11 -> true)
case Day1.part2(data), do: (31 -> true)

data = File.read!("day1.in")
ans = Day1.part1(data)
IO.puts("part1: #{ans}")
ans = Day1.part2(data)
IO.puts("part2: #{ans}")
