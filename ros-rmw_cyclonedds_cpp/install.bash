#!/usr/bin/env bash

LINE='export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp'
FILE="$HOME/.bashrc"

# Check if the line already exists (exact match)
if grep -Fxq "$LINE" "$FILE"; then
    echo "cyclone dds already exists in $FILE"
else
    echo "$LINE" >> "$FILE"
    echo "cyclone dds added to $FILE"
fi