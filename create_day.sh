#! /bin/zsh

day=$1

if [ -z "$day" ]; then
  echo "Usage: 
>./create_day.sh day_name"
  exit 0
fi

echo "Creating module day_$1.ex..."
if [ -d "./lib/day_$1" ]; then
	echo "./lib/day_$1 already exists."
else
	mkdir ./lib/day_$1
fi

if [ -f "./lib/day_$1/day_$1.ex" ]; then
	echo "./lib/day_$1/day_$1.ex already exists."
else
	touch ./lib/day_$1/day_$1.ex
fi

echo "Creating input file day_$1.txt..."
if [ -d "./input" ]; then
	echo "./input already exists."
else
	mkdir ./input
fi

if [ -f "./input/day_$1.txt" ]; then
	echo "./input/day_$1.txt already exists."
else
	touch ./input/day_$1.txt
fi

echo "Creating test input file day_$1.txt..."
if [ -d "./test/input" ]; then
	echo "./test/input already exists."
else
	mkdir -p ./test/input
fi
if [ -f "./test/input/day_$1.txt" ]; then
	echo "./test/input/day_$1.txt already exists."
else
	touch ./test/input/day_$1.txt
fi
