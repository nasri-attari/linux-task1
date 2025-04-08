#!/bin/bash

# Create a process
sleep 600 &
process_id=$!

# Print the Process ID of the created process
echo "Process created with PID: $process_id"

# Run in the background for 10 minutes
echo "The script will run for 10 minutes..."

# Check every 10 seconds if the process is running and try to kill it
for i in {1..60}
do
    # Check if the process is running using ps and process_id
    if ps -p $process_id > /dev/null
    then
        echo "Process with PID $process_id is still running..."
    else
        echo "Process with PID $process_id has already completed."
        break
    fi

    # Try to kill the process after 1 minute (60 seconds)
    if [ $i -eq 6 ]; then
        echo "Attempting to kill process with PID $process_id..."
        kill $process_id

        # Wait a bit to make sure the kill command works
        sleep 5

        # Verify if the process is still running
        if ps -p $process_id > /dev/null
        then
            echo "Failed to kill process with PID $process_id. It is still running."
        else
            echo "Successfully killed the process with PID $process_id."
            break
        fi
    fi

    # Wait for 10 seconds before checking again
    sleep 10
done

echo "Script finished."
