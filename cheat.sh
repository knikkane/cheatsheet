#!/usr/bin/env bash

# Path to your cheat sheet
CHEAT_FILE="$HOME/PATH_TO/cheatsheet.md"

cheat() {
    local topic="$1"

    # Validate input
    if [[ -z "$topic" ]]; then
        echo "Usage: cheat <topic>"
        echo "Run 'cheat --list' to see all topics."
        return 1
    fi

    if [[ ! -f "$CHEAT_FILE" ]]; then
        echo "Error: Cheat sheet not found at $CHEAT_FILE"
        return 1
    fi	

    # List available topics
    if [[ "$topic" == "--list" ]]; then
        sed '1s/^\xEF\xBB\xBF//' "$CHEAT_FILE" | grep -oP '^##\s*\K.*'
        return 0
    fi

    # Extract section matching the topic
    local result
    result=$(sed '1s/^\xEF\xBB\xBF//' "$CHEAT_FILE" | awk -v topic="$topic" '
        BEGIN { 
            IGNORECASE = 1
            found = 0
        }
        /^##/ {
            # If match not found
            if (found) exit
            
            # Extract heading text
            heading = $0
            sub(/^##[ \t]*/, "", heading)
            
            # Check if this is the topic we want
            if (tolower(heading) == tolower(topic)) {
                found = 1
                next
            }
        }
        found { print }
    ')

    # Check if topic was found
    if [[ -z "$result" ]]; then
        echo "Topic '$topic' not found."
        echo "Run 'cheat --list' to see all available topics."
        return 1
    fi

    echo "$result"
}

# Tab complete
_cheat_complete() {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local topics
 
    #Check that the file exists
    [[ ! -f "$CHEAT_FILE" ]] && return 1
 
    topics=$(sed '1s/^\xEF\xBB\xBF//' "$CHEAT_FILE" | grep -oP '^##\s*\K.*')
    COMPREPLY=( $(compgen -W "$topics" -- "$cur") )
}

complete -F _cheat_complete cheat
