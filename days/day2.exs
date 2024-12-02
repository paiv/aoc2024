#!/usr/bin/env elixir

defmodule Day2 do
  defp parse(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(fn s -> String.split(s) |> Enum.map(&String.to_integer/1) end)
  end

  defp valid?(row) do
    Enum.all?(row, &(&1 in [1, 2, 3])) ||
      Enum.all?(row, &(&1 in [-1, -2, -3]))
  end

  defp safe?(row) do
    Enum.zip(row, Enum.drop(row, 1))
    |> Enum.map(fn {x, y} -> x - y end)
    |> valid?()
  end

  defp tolerable?(row) do
    safe?(row) ||
      Enum.any?(0..(length(row) - 1), fn i ->
        List.delete_at(row, i)
        |> safe?()
      end)
  end

  def part1(data) do
    parse(data)
    |> Enum.map(&safe?/1)
    |> Enum.map(&case(&1, do: (true -> 1; false -> 0)))
    |> Enum.sum()
  end

  def part2(data) do
    parse(data)
    |> Enum.map(&tolerable?/1)
    |> Enum.map(&case(&1, do: (true -> 1; false -> 0)))
    |> Enum.sum()
  end
end

data = """
7 6 4 2 1
1 2 7 8 9
9 7 6 2 1
1 3 2 4 5
8 6 4 4 1
1 3 6 7 9
"""

case Day2.part1(data), do: (2 -> true)
case Day2.part2(data), do: (4 -> true)

data = File.read!("day2.in")
ans = Day2.part1(data)
IO.puts("part1: #{ans}")
ans = Day2.part2(data)
IO.puts("part2: #{ans}")
