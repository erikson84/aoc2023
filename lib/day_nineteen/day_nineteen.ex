defmodule AdventOfCode.DayNineteen do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayNineteen` for AoC '23.
  """
  def first_star(path) do
    {:ok, str} = File.read(path)

    [raw_rules, raw_parts] = String.split(str, "\n\n", trim: true)

    parts = raw_parts |> String.split("\n", trim: true) |> Enum.map(&process_part/1)

    rules =
      raw_rules
      |> String.split("\n", trim: true)
      |> Enum.map(&process_rule/1)
      |> Enum.reduce(fn rule, acc -> Map.merge(acc, rule) end)

    parts
    |> Enum.reject(&(process_part(&1, rules) == :R))
    |> Enum.map(fn %{x: x, m: m, a: a, s: s} -> x + m + a + s end)
    |> Enum.sum()
  end

  def second_star(path) do
    {:ok, str} = File.read(path)

    [raw_rules, _] = String.split(str, "\n\n", trim: true)

    rules =
      raw_rules
      |> String.split("\n", trim: true)
      |> Enum.map(&map_rule/1)
      |> Enum.reduce(fn rule, acc -> Map.merge(acc, rule) end)

    process_ranges(%{x: {1, 4000}, m: {1, 4000}, a: {1, 4000}, s: {1, 4000}}, rules, :in)
    |> List.flatten()
    |> Enum.reject(fn {val, _} -> val == :R end)
    |> Enum.map(fn {_,
                    %{
                      x: {x_start, x_stop},
                      m: {m_start, m_stop},
                      a: {a_start, a_stop},
                      s: {s_start, s_stop}
                    }} ->
      (x_stop - x_start + 1) * (m_stop - m_start + 1) * (a_stop - a_start + 1) *
        (s_stop - s_start + 1)
    end)
    |> Enum.sum()
  end

  defp process_part(part, rules, rule \\ :in) do
    Enum.reduce_while(rules[rule], part, fn
      r, acc ->
        case r.(acc) do
          :A -> {:halt, :A}
          :R -> {:halt, :R}
          :next -> {:cont, acc}
          new_rule -> {:halt, new_rule}
        end
    end)
    |> case do
      :A -> :A
      :R -> :R
      new_rule -> process_part(part, rules, new_rule)
    end
  end

  defp process_rule(str) do
    [[_, name, rules]] = Regex.scan(~r/([a-z]+){(.*)}/, str)

    String.split(rules, ",")
    |> Enum.map(&parse_cond/1)
    |> then(&%{String.to_atom(name) => &1})
  end

  defp parse_cond(str) do
    cond do
      str =~ ~r/(<|>)/ ->
        Regex.named_captures(
          ~r/(?<parameter>x|m|a|s)(?<op><|>)(?<value>[0-9]+)\:(?<out>R|A|[a-z]+)/,
          str
        )
        |> make_function()

      str ->
        fn _ -> String.to_atom(str) end
    end
  end

  defp make_function(map) do
    par = String.to_atom(map["parameter"])

    op =
      case map["op"] do
        "<" -> &Kernel.</2
        ">" -> &Kernel.>/2
      end

    val = String.to_integer(map["value"])
    out = String.to_atom(map["out"])

    fn piece ->
      if op.(piece[par], val), do: out, else: :next
    end
  end

  defp map_rule(str) do
    [[_, name, rules]] = Regex.scan(~r/([a-z]+){(.*)}/, str)

    String.split(rules, ",")
    |> Enum.map(&map_cond/1)
    |> then(&%{String.to_atom(name) => &1})
  end

  defp map_cond(str) do
    cond do
      str =~ ~r/(<|>)/ ->
        Regex.named_captures(
          ~r/(?<parameter>x|m|a|s)(?<op><|>)(?<value>[0-9]+)\:(?<out>R|A|[a-z]+)/,
          str
        )
        |> Map.new(fn
          {"parameter", par} -> {:parameter, String.to_atom(par)}
          {"op", op} -> {:op, String.to_atom(op)}
          {"value", val} -> {:value, String.to_integer(val)}
          {"out", out} -> {:out, String.to_atom(out)}
        end)

      str ->
        String.to_atom(str)
    end
  end

  defp process_ranges(map, _, :A), do: {:A, map}
  defp process_ranges(map, _, :R), do: {:R, map}

  defp process_ranges(map, rules, rule) do
    Enum.reduce(rules[rule], [map], fn
      %{parameter: par, op: op, value: val, out: out}, [cur_map | acc] ->
        [accept, reject] = split_range(cur_map, par, op, val)
        [reject, {out, accept} | acc]

      name, [cur_map | acc] ->
        [{name, cur_map} | acc]
    end)
    |> Enum.map(fn {name, cur_map} -> process_ranges(cur_map, rules, name) end)
  end

  defp split_range(map, par, op, val) do
    {start, stop} = map[par]

    if op == :< do
      [%{map | par => {start, val - 1}}, %{map | par => {val, stop}}]
    else
      [%{map | par => {val + 1, stop}}, %{map | par => {start, val}}]
    end
  end

  defp process_part(str) do
    Regex.named_captures(
      ~r/\{x\=(?<x>[0-9]+),m\=(?<m>[0-9]+),a\=(?<a>[0-9]+),s\=(?<s>[0-9]+)}/,
      str
    )
    |> Map.new(fn {name, value} -> {String.to_atom(name), String.to_integer(value)} end)
  end
end
