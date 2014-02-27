function check_only_one_running {

	proc_name=$1
	running_count=$( procps aux | grep "$proc_name" | grep -v "grep" | wc -l )
	if ! [[ $running_count -gt 0 ]]; then
		echo "You can run only one instance of [$proc_name]. Exitting!"
		exit 1
	fi

}