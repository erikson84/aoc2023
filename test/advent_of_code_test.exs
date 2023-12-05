defmodule AdventOfCode.DayOneTest do
  use ExUnit.Case

  test "Day one, first star" do
    assert AdventOfCode.DayOne.first_star("./test/input/day_one_first.txt") == 142
  end

  test "Day one, second star" do
    assert AdventOfCode.DayOne.second_star("./test/input/day_one_second.txt") == 281
  end
end

defmodule AdventOfCode.DayTwoTest do
  use ExUnit.Case

  test "Day two, first star" do
    assert AdventOfCode.DayTwo.first_star("./test/input/day_two.txt") == 8
  end

  test "Day two, second star" do
    assert AdventOfCode.DayTwo.second_star("./test/input/day_two.txt") == 2286
  end
end

defmodule AdventOfCode.DayThreeTest do
  use ExUnit.Case

  test "Day three, first star" do
    assert AdventOfCode.DayThree.first_star("./test/input/day_three.txt") == 4361
  end

  test "Day three, second star" do
    assert AdventOfCode.DayThree.second_star("./test/input/day_three.txt") == 467_835
  end
end
