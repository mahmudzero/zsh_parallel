#!/usr/bin/env zsh
# set -x

export PARAM_ONE='internal_one'
export PARAM_TWO='internal_two'
export PARAM_THREE='internal_three'

echo 0 > './running.count'
if [[ -f "./write.lock" ]]; then
	rm ./write.lock
fi

main () {
	eval export PARAM_ONE="external_one_$1"; export PARAM_TWO="external_two_$1" export PARAM_THREE="external_three_$1"; ./helper.zsh
	echo 'END OF PROCESS: ' $1
	write_mutex 0
}

write_mutex () {
	if [[ -f "./write.lock" ]]; then
		echo "cannot write while file is locked..."
		sleep 10
		write_mutex $1
	else
		touch ./write.lock
		number_running=$(cat "./running.count")
		if [[ $1 -eq 0 ]]; then
			number_running=$((($number_running - 1)))
		fi
		if [[ $1 -eq 1 ]]; then
			number_running=$((($number_running + 1)))
		fi
		echo $number_running > "./running.count"
		rm ./write.lock
	fi
}

counter=0
while [[ $counter -lt 10 ]]; do
	number_running=$(cat "./running.count")
	if [[ $number_running -le 4 ]]; then
		write_mutex 1
		main $counter &
		echo 'COUNTER:       ' $counter
		echo 'I PARAM ONE:   ' $PARAM_ONE
		echo 'I PARAM TWO:   ' $PARAM_TWO
		echo 'I PARAM THREE: ' $PARAM_THREE
		counter=$((($counter + 1)))
	else
		echo 'sleeping because processes is full...'
		sleep 10
	fi
done

current_number_running=$(cat "./running.count")
while [[ $current_number_running -gt 0 ]]; do
	echo "still waiting on $current_number_running processes..."
	current_number_running=$(cat "./running.count")
	sleep 5
done

echo 'DONE'
