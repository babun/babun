function check_only_one_running {
    proc_name=$1
    running_count=$( procps aux | grep "$proc_name" | grep -v "grep" | wc -l )
    # procps aux will be shown as the process as well (that the reason why it's 2 not 1)
    if [[ $running_count -gt 2 ]]; then
            echo "You can only run one instance of $proc_name. Exitting!"
            exit 1
    fi
}
