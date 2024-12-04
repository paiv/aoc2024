#!/usr/bin/env elixir

defmodule Day4 do
  defp parse(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&List.to_tuple/1)
    |> List.to_tuple()
  end

  defp row_words(lines) do
    n = tuple_size(lines)

    Stream.flat_map(0..(n - 1)//1, fn i ->
      row = elem(lines, i)
      n = tuple_size(row)

      Stream.map(0..(n - 4)//1, fn i ->
        elem(row, i) <> elem(row, i + 1) <> elem(row, i + 2) <> elem(row, i + 3)
      end)
    end)
  end

  defp col_words(lines) do
    n = tuple_size(lines)

    Stream.flat_map(0..(n - 4)//1, fn i ->
      r1 = elem(lines, i)
      r2 = elem(lines, i + 1)
      r3 = elem(lines, i + 2)
      r4 = elem(lines, i + 3)
      n = tuple_size(r1)

      Stream.map(0..(n - 1)//1, fn i ->
        elem(r1, i) <> elem(r2, i) <> elem(r3, i) <> elem(r4, i)
      end)
    end)
  end

  defp diag_words(lines) do
    n = tuple_size(lines)

    Stream.flat_map(0..(n - 4)//1, fn i ->
      r1 = elem(lines, i)
      r2 = elem(lines, i + 1)
      r3 = elem(lines, i + 2)
      r4 = elem(lines, i + 3)
      n = tuple_size(r1)

      Stream.flat_map(0..(n - 4)//1, fn i ->
        Stream.concat(
          [elem(r1, i) <> elem(r2, i + 1) <> elem(r3, i + 2) <> elem(r4, i + 3)],
          [elem(r1, i + 3) <> elem(r2, i + 2) <> elem(r3, i + 1) <> elem(r4, i)]
        )
      end)
    end)
  end

  defp xmas?(s) do
    s == "XMAS" or s == "SAMX"
  end

  defp mas?({a, b}) do
    (a == "MAS" or a == "SAM") and (b == "MAS" or b == "SAM")
  end

  defp extract_words(data) do
    lines = parse(data)

    Stream.concat([
      row_words(lines),
      col_words(lines),
      diag_words(lines)
    ])
  end

  defp extract_xs(data) do
    lines = parse(data)
    n = tuple_size(lines)

    Stream.flat_map(0..(n - 3)//1, fn i ->
      r1 = elem(lines, i)
      r2 = elem(lines, i + 1)
      r3 = elem(lines, i + 2)
      n = tuple_size(r1)

      Stream.map(0..(n - 3)//1, fn i ->
        {
          elem(r1, i) <> elem(r2, i + 1) <> elem(r3, i + 2),
          elem(r1, i + 2) <> elem(r2, i + 1) <> elem(r3, i)
        }
      end)
    end)
  end

  def part1(data) do
    extract_words(data)
    |> Stream.filter(&xmas?/1)
    |> Enum.count()
  end

  def part2(data) do
    extract_xs(data)
    |> Stream.filter(&mas?/1)
    |> Enum.count()
  end
end

data = """
MMMSXXMASM
MSAMXMSMSA
AMXSXMAAMM
MSAMASMSMX
XMASAMXAMM
XXAMMXXAMA
SMSMSASXSS
SAXAMASAAA
MAMMMXMMMM
MXMXAXMASX
"""

case Day4.part1(data), do: (18 -> true)
case Day4.part2(data), do: (9 -> true)

data = File.read!("day4.in")
ans = Day4.part1(data)
IO.puts("part1: #{ans}")
ans = Day4.part2(data)
IO.puts("part2: #{ans}")
