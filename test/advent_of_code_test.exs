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

defmodule AdventOfCode.DayFourTest do
  use ExUnit.Case

  test "Day four, first star" do
    assert AdventOfCode.DayFour.first_star("./test/input/day_four.txt") == 13
  end

  test "Day four, second star" do
    assert AdventOfCode.DayFour.second_star("./test/input/day_four.txt") == 30
  end
end

defmodule AdventOfCode.DayFiveTest do
  use ExUnit.Case

  test "Day five, first star" do
    assert AdventOfCode.DayFive.first_star("./test/input/day_five.txt") == 35
  end

  test "Day five, second star" do
    assert AdventOfCode.DayFive.second_star("./test/input/day_five.txt") == 46
  end
end

defmodule AdventOfCode.DaySixTest do
  use ExUnit.Case

  test "Day six, first star" do
    assert AdventOfCode.DaySix.first_star("./test/input/day_six.txt") == 288
  end

  test "Day six, second star" do
    assert AdventOfCode.DaySix.second_star("./test/input/day_six.txt") == 71503
  end
end

defmodule AdventOfCode.DaySevenTest do
  use ExUnit.Case

  test "Day seven, first star" do
    assert AdventOfCode.DaySeven.first_star("./test/input/day_seven.txt") == 6440
  end

  test "Day seven, second star" do
    assert AdventOfCode.DaySeven.second_star("./test/input/day_seven.txt") == 5905
  end
end

defmodule AdventOfCode.DayEightTest do
  use ExUnit.Case

  test "Day eight, first star" do
    assert AdventOfCode.DayEight.first_star("./test/input/day_eight_first.txt") == 2
  end

  test "Day eight, second star" do
    assert AdventOfCode.DayEight.second_star("./test/input/day_eight_second.txt") == 6
  end
end

defmodule AdventOfCode.DayNineTest do
  use ExUnit.Case

  test "Day nine, first star" do
    assert AdventOfCode.DayNine.first_star("./test/input/day_nine.txt") == 114
  end

  test "Day nine, second star" do
    assert AdventOfCode.DayNine.second_star("./test/input/day_nine.txt") == 2
  end
end

defmodule AdventOfCode.DayTenTest do
  use ExUnit.Case

  test "Day ten, first star" do
    assert AdventOfCode.DayTen.first_star("./test/input/day_ten.txt") == 8
  end

  test "Day ten, second star" do
    assert AdventOfCode.DayTen.second_star("./test/input/day_ten.txt") == 1
  end
end
