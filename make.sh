#!/bin/bash

WINE_EXE=wine
MQL4_COMPILER=~/Documents/mql.exe
MT4_HOME=~/mt4
DEST_DIRS=(~/mt4/MQL4 ~/tmt4/MQL4)

set +e

cp -f "$MQL4_COMPILER" "$MT4_HOME"

"$WINE_EXE" "$MT4_HOME/mql.exe" /mql4 /o CandleBreakout.mq4
"$WINE_EXE" "$MT4_HOME/mql.exe" /mql4 /o CandleBreakoutEA.mq4

for d in ${DEST_DIRS[@]}; do
  cp CandleBreakout.ex4 "$d/Indicators/"
  cp CandleBreakoutEA.ex4 "$d/Experts/"
done

