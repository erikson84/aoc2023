# Advent of Code 2023: Elixir Solutions

Solving the [Advent of Code 2023](https://adventofcode.com/2023/) challenges in `Elixir`.

## Structure

The solution for each day is stored in a child module, and the functions required to obtain 
each solution are named `first_star/1` and `second_star/1`. They each take a 
`path` argument, which makes it possible to run them with test inputs.

## CLI

To obtain the result for each challenge, the project has an `escript` module
that allows to run a specific day and star on the provided input.

To compile the CLI application, you must run:

```
> mix escript.build
```

Then, you can run any implemented solution with:

```
> ./advent_of_code --day \d+ --star (1|2)
```

The `--day` argument must be a number between 1 and 24, i.e, for the advent day.
The `--star` argument must be either a 1 or a 2, for the first or second star.
