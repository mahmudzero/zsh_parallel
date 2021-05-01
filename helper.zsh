#!/usr/bin/env zsh
timeout=$(awk -v min=10 -v max=20 'BEGIN{srand(); print int(min+rand()*(max-min+1))}')
sleep $timeout
echo 'PARAM ONE:   ' $PARAM_ONE
echo 'PARAM TWO:   ' $PARAM_TWO
echo 'PARAM THREE: ' $PARAM_THREE
