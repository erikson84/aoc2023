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
    |> process_pulse([], [{"broadcaster", "button", :low}])
  end

  defp process_pulse(_, history, []), do: history

  defp process_pulse(modules, history, [{target, origin, pulse} | acc]) do
    IO.inspect(acc)

    case modules[target] do
      %FlipFlop{state: :broadcaster, targets: targets} ->
        process_pulse(
          modules,
          [pulse | history],
          acc ++ Enum.map(targets, fn dest -> {dest, target, pulse} end)
        )

      %FlipFlop{} when pulse == :high ->
        process_pulse(modules, [pulse | history], acc)

      %FlipFlop{state: :off, targets: targets} ->
        process_pulse(
          put_in(modules, [target, Access.key!(:state)], :on),
          [pulse | history],
          acc ++ Enum.map(targets, fn dest -> {dest, target, :high} end)
        )

      %FlipFlop{state: :on, targets: targets} ->
        process_pulse(
          put_in(modules, [target, Access.key!(:state)], :off),
          [pulse | history],
          acc ++ Enum.map(targets, fn dest -> {dest, target, :low} end)
        )

      %Conjunction{targets: targets} ->
        update_modules = put_in(modules, [target, Access.key!(:state), origin], pulse)

        process_pulse(
          update_modules,
          [pulse | history],
          acc ++
            Enum.map(targets, fn dest ->
              if Enum.all?(Map.values(update_modules[target].state), &(&1 == :high)),
                do: {dest, target, :low},
                else: {dest, target, :high}
            end)
        )
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
    for {name_conj, conj = %Conjunction{}} <- modules,
        {name, module} <- modules,
        name_conj in module.targets,
        into: %{} do
      {name_conj, put_in(conj, [Access.key!(:state), name], :low)}
    end
    |> then(&Map.merge(modules, &1))
  end
end
