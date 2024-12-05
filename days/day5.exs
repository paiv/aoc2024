#!/usr/bin/env elixir

defmodule Day5 do
  defp parse_rules(data) do
    data
    |> String.split()
    |> Enum.map(fn line ->
      line
      |> String.split("|", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
    |> Enum.reduce(%{}, fn [x, y], m ->
      ps = [y | m[x] || []]
      Map.put(m, x, ps)
    end)
  end

  defp parse_jobs(data) do
    data
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      line
      |> String.split(",", trim: true)
      |> Enum.map(&String.to_integer/1)
    end)
  end

  defp valid?(job, rules) do
      {t, _} =
        job
        |> Enum.reduce({true, []}, fn x, {t, prev} ->
          {
            t && not Enum.any?(rules[x] || [], & Enum.member?(prev, &1)),
            [x | prev]
          }
        end)
      t
  end

  defp fixup(job, rules) do
    Enum.sort(job, fn x, y ->
      Enum.member?(rules[x] || [], y)
    end)
  end

  def part1(data) do
    [rules, jobs] = String.split(data, "\n\n", trim: true)
    rules = parse_rules(rules)

    parse_jobs(jobs)
    |> Stream.filter(& valid?(&1, rules))
    |> Stream.map(& Enum.at(&1, div(length(&1), 2)))
    |> Enum.sum()
  end

  def part2(data) do
    [rules, jobs] = String.split(data, "\n\n", trim: true)
    rules = parse_rules(rules)

    parse_jobs(jobs)
    |> Stream.filter(& not valid?(&1, rules))
    |> Stream.map(& fixup(&1, rules))
    |> Stream.map(& Enum.at(&1, div(length(&1), 2)))
    |> Enum.sum()
  end
end

data = """
47|53
97|13
97|61
97|47
75|29
61|13
75|53
29|13
97|29
53|29
61|53
97|53
61|29
47|13
75|47
97|75
47|61
75|61
47|29
75|13
53|13

75,47,61,53,29
97,61,53,29,13
75,29,13
75,97,47,61,53
61,13,29
97,13,75,29,47
"""

case Day5.part1(data), do: (143 -> true)
case Day5.part2(data), do: (123 -> true)

data = File.read!("day5.in")
ans = Day5.part1(data)
IO.puts("part1: #{ans}")
ans = Day5.part2(data)
IO.puts("part2: #{ans}")
