#!/bin/bash -e

# pick tool from args
tool=$1
echo "* Starting benchmark for $tool ..."
cd $tool

# cleanup
sum=0
rm -f bench.log

# pick date command
DATE="date"

if [ "$(node -e 'console.log(require("os").platform())')" == "darwin" ]; then
  DATE="gdate" # assuming this is installed
fi

# replicate chars
function dup() {
  for ((i=0;i<$2;i++)); do
    echo -n "$1"
  done
}

# set progress bar size
export PBAR_SIZE=30

# run benchmarks
for ((i=0;i<MAX_ITERATIONS;i++)); do
  start=$($DATE +"%s%N")
  $tool $(cat args 2>/dev/null || echo "")
  e="$?"
  end=$($DATE +"%s%N")
  dur=$[end-start]

  # if errors out, fail entire benchmark
  if [ "$e" -ne "0" ]; then
    exit $e
  fi

  # keep track
  echo "[$tool] #$i: $dur ns"
  echo $dur >> bench.log

  # print progress
  n=$(awk "BEGIN { printf(\"%.0f\n\", ($i/$MAX_ITERATIONS)*$PBAR_SIZE) }")
  echo -ne "benchmarking $tool: [$(dup '#' $n)$(dup ' ' $[PBAR_SIZE-n])]$(dup ' ' 20)\r" >&2
done