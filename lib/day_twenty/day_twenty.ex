defmodule AdventOfCode.DayTwenty do
  @moduledoc """
  Implements solutions for the first and second star
  of `DayTwenty` for AoC '23.
  """
  defmodule FlipFlop do
    defstruct state: :off, targets: []

    @type t :: %FlipFlop{
            state: :on | :off | :broadcaster,
            targets: [String.t()]
          }
  end

  defmodule Conjunction do
    defstruct state: %{}, targets: []

    @type t :: %Conjunction{
            state: %{String.t() => :low | :high},
            targets: [String.t()]
          }
  end

  def first_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> Enum.map(&process_module/1)
    |> Map.new()
    |> find_inputs()
    |> then(
      &Enum.reduce(1..1000, {&1, []}, fn _, {mod, hist} ->
        {update_mod, new_hist} = process_pulse(mod, [], [{"broadcaster", "button", :low}])
        {update_mod, hist ++ new_hist}
      end)
    )
    |> elem(1)
    |> Enum.frequencies_by(fn {_, _, pulse} -> pulse end)
    |> Map.values()
    |> Enum.product()
  end

  def second_star(path) do
    {:ok, file} = File.read(path)

    file
    |> String.split("\n", trim: true)
    |> Enum.map(&process_module/1)
    |> Map.new()
    |> find_inputs()
    |> then(
      &Enum.reduce(1..5000, {&1, []}, fn el, {mod, hist} ->
        {update_mod, new_hist} = process_pulse(mod, [], [{"broadcaster", "button", :low}])
        {update_mod, [{el, new_hist} | hist]}
      end)
    )
    |> elem(1)
    |> Enum.map(fn {press, list} ->
      {press, Enum.filter(list, &match?({"xm", _, :high}, &1)) |> Enum.uniq()}
    end)
    |> Enum.reject(fn
      {_, ls} -> ls == []
    end)
    |> Enum.map(fn {press, _} -> press end)
    |> Enum.product()
  end

  defp process_pulse(modules, history, []), do: {modules, history}

  defp process_pulse(modules, history, [message = {target, origin, pulse} | acc]) do
    case modules[target] do
      %FlipFlop{state: :broadcaster, targets: targets} ->
        process_pulse(
          modules,
          [message | history],
          acc ++ Enum.map(targets, fn dest -> {dest, target, pulse} end)
        )

      %FlipFlop{} when pulse == :high ->
        process_pulse(modules, [message | history], acc)

      %FlipFlop{state: :off, targets: targets} ->
        process_pulse(
          put_in(modules, [target, Access.key!(:state)], :on),
          [message | history],
          acc ++ Enum.map(targets, fn dest -> {dest, target, :high} end)
        )

      %FlipFlop{state: :on, targets: targets} ->
        process_pulse(
          put_in(modules, [target, Access.key!(:state)], :off),
          [message | history],
          acc ++ Enum.map(targets, fn dest -> {dest, target, :low} end)
        )

      %Conjunction{targets: targets} ->
        update_modules = put_in(modules, [target, Access.key!(:state), origin], pulse)

        process_pulse(
          update_modules,
          [message | history],
          acc ++
            Enum.map(targets, fn dest ->
              if Enum.all?(Map.values(update_modules[target].state), &(&1 == :high)),
                do: {dest, target, :low},
                else: {dest, target, :high}
            end)
        )

      nil ->
        process_pulse(modules, [message | history], acc)
    end
  end

  defp process_module(line) do
    case Regex.scan(~r/([\%\&]?[a-z]+) -> ([a-z\,\s]+)/, line) do
      [[_, "broadcaster", dest]] ->
        {"broadcaster",
         %FlipFlop{state: :broadcaster, targets: String.split(dest, ", ", trim: true)}}

      [[_, "%" <> name, dest]] ->
        {name, %FlipFlop{targets: String.split(dest, ", ", trim: true)}}

      [[_, "&" <> name, dest]] ->
        {name, %Conjunction{targets: String.split(dest, ", ", trim: true)}}
    end
  end

  defp find_inputs(modules) do
    for {name_conj, %Conjunction{}} <- modules,
        {name, module} <- modules,
        name_conj in module.targets,
        reduce: modules do
      acc -> put_in(acc, [name_conj, Access.key!(:state), name], :low)
    end
  end
end
