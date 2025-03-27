#!/bin/bash

#----------------------------------------------------------Initialize--------------------------------------------------------------
# initialize grid as a multi-dimensional array
declare -A grid
declare player1_score=0
declare player2_score=0
declare winner=""

#---------------------------------------------------------display_empty_grid---------------------------------------------------------

display_empty_grid() {
    local size=$1
    for ((i = 1; i <= size; i++)); do
        for ((j = 1; j <= size; j++)); do
            grid[$i,$j]=" "  # populate the grid with empty spaces
            echo -n "| " # display delimiter for each cell
        done
        echo "|"  # end of row
    done
}

#--------------------------------------------------------display_grid_from_file-----------------------------------------------------
display_grid_from_file() {
    local file_path=$1

    # read the size of the grid from the first line of the file
    local size=$(head -n 1 "$file_path" | awk -F '|' '{print NF-2}')

    # update global variable N
    N=$size

    # read file content line by line and populate the grid
    while IFS= read -r line; do
        # remove the first and last '|' characters from the line
        line=${line#|}
        line=${line%|}

        # split the line using '|' as the delimiter
        IFS='|' read -ra cells <<< "$line"

        # trim the array to the size of the grid
        cells=("${cells[@]:0:size}")

        for ((i = 0; i < size; i++)); do
            grid[$((line_num + 1)),$((i + 1))]=${cells[i]} # Populate the grid with characters from the row
        done
        ((line_num++)) #increment line number
    done < "$file_path"

    display_grid # display the loaded grid
}

#---------------------------------------------------------------display_grid-----------------------------------------------------

display_grid() {
    for ((i = 1; i <= N; i++)); do
        for ((j = 1; j <= N; j++)); do
            echo -n "|${grid[$i,$j]}" # display delimiter for each cell
        done
        echo "|"  # end of row
    done
    }
#------------------------------------------------------------display_scores------------------------------------------------------

display_scores(){
    echo " ________________________________________________________ "
    echo "|                        Scores:                         |"
    echo "|________________________________________________________|"
    echo "|                           |                            |"
    printf "| %26s| %-26s |\n" "$player1: $player1_score" "$player2_score: $player2" 
    echo "|___________________________|____________________________|"
    echo 
}

#----------------------------------------------------------update_scores--------------------------------------------------------
update_scores() {
    local player_mark=$1
    local opponent_mark=$2

    # Initialize score changes
    local player_score_change=0
    local opponent_score_change=0

    # Check for alignments in the grid
    if check_alignment "$player_mark"; then
        ((player_score_change += 2)) # Player gets +2 points for alignment
    fi
    if check_alignment "$opponent_mark"; then
        ((player_score_change -= 3)) #player gets -3 for causing an alignment for opponent
        
    fi
    
    
    # Update the scores
    
    if [[ "$((moves % 2))" -eq 0 ]]; then
        ((player1_score += player_score_change))
        ((player2_score += opponent_score_change))
    else
        ((player2_score += player_score_change))
        ((player1_score += opponent_score_change))
    fi
    
}

#-----------------------------------------------------------check_alignment-----------------------------------------------
check_alignment() {
    local mark=$1
    local aligned=false

    # Check horizontal alignments
    for ((i = 1; i <= N; i++)); do
        local count=0
        for ((j = 1; j <= N; j++)); do
            if [[ "${grid[$i,$j]}" == "$mark" ]]; then
                ((count++))
            fi
        done
        if [[ $count -eq N ]]; then
            aligned=true
            break
        fi
    done

    # Check vertical alignments
    if ! $aligned; then
        for ((j = 1; j <= N; j++)); do
            local count=0
            for ((i = 1; i <= N; i++)); do
                if [[ "${grid[$i,$j]}" == "$mark" ]]; then
                    ((count++))
                fi
            done
            if [[ $count -eq N ]]; then
                aligned=true
                break
            fi
        done
    fi

    # Check diagonal "\" alignment
    if ! $aligned; then
        local count=0
        for ((i = 1; i <= N; i++)); do
            if [[ "${grid[$i,$i]}" == "$mark" ]]; then
                ((count++))
            fi
        done
        if [[ $count -eq N ]]; then
            aligned=true
        fi
    fi

    # Check diagonal "/" alignment
    if ! $aligned; then
        local count=0
        for ((i = 1; i <= N; i++)); do
            if [[ "${grid[$i,$((N - i + 1))]}" == "$mark" ]]; then
                ((count++))
            fi
        done
        if [[ $count -eq N ]]; then
            aligned=true
        fi
    fi
    
    # Check diagonal "\" alignment
    if ! $aligned; then
        local count=0
        for ((i = 1; i <= N; i++)); do
            if [[ "${grid[$i,$i]}" == "$mark" ]]; then
            ((count++))
            fi
        done
        if [[ $count -eq N ]]; then
        aligned=true
        fi
    fi


    $aligned
}

#-----------------------------------------------------------move_1------------------------------------------------------
# Function to place player marks in an empty cell
move_1() {
    local size=$N
    echo "Enter the row number (1-$size):"
    read row
    echo "Enter the column number (1-$size):"
    read col
    while true; do
        # Validate the input coordinates
        if [[ "$row" -lt 1 || "$row" -gt "$size" || "$col" -lt 1 || "$col" -gt "$size" ]]; then
            echo "Invalid coordinates. Your turn if over :( ."
            return
        fi

        # Check if the cell is already occupied
        if [[ "${grid[$row,$col]}" != " " ]]; then
            echo "Cell already occupied. Your turn if over :( ."
            return
        fi

        # Place the mark in the selected cell
        if [[ "$((moves % 2))" -eq 0 ]]; then
            grid[$row,$col]="X"
            update_scores "X" "O"
        else
            grid[$row,$col]="O"
            update_scores "O" "X"
        fi

        # Display the updated grid
        echo
        echo "Updated grid:"
        display_grid
        display_scores
        break
    done
}

#-------------------------------------------------------------move_2--------------------------------------------------------------
# Function to remove player marks from an occupied cell
move_2() {
    local size=$N
    echo "Enter the row number (1-$size):"
    read row
    echo "Enter the column number (1-$size):"
    read col
    
    # Add 1 point for playing Move 2
    if [[ "$((moves % 2))" -eq 0 ]]; then
        (( player1_score += 1 ))
    else
        (( player2_score += 1 ))
    fi
    
    while true; do
        # Validate the input coordinates
        if [[ "$row" -lt 1 || "$row" -gt "$size" || "$col" -lt 1 || "$col" -gt "$size" ]]; then
            echo "Invalid coordinates. Your turn if over :( ."
            return
        fi

        # Check if the cell is already empty
        if [[ "${grid[$row,$col]}" == " " ]]; then
            echo "Cell is already empty. Your turn if over :( ."
            display_grid
            return
        fi

        # Remove the mark from the selected cell
        grid[$row,$col]=" "

        # Display the updated grid
        echo
        echo "Updated grid:"
        display_grid
        display_scores
        break
    done
}

#--------------------------------------------------------------move_3---------------------------------------------------------
# Function to exchange rows on the grid
move_3() {
    local size=$N
    echo "Enter the rows to exchange (e.g., 'rxy' where 'x' and 'y' are row numbers):"
    read rows
    
    # Penalize players for Move 3
    if [[ "$((moves % 2))" -eq 0 ]]; then
        (( player1_score -= 1 ))
    else
        (( player2_score -= 1 ))
    fi
    
    while true; do
        # Extract row numbers from user input
        rchar=${rows:0:1}
        row1=${rows:1:1}
        row2=${rows:2:1}

        # Validate row numbers
        if [[ "$rchar" != "r" || "$row1" -lt 1 || "$row1" -gt "$size" || "$row2" -lt 1 || "$row2" -gt "$size" ]]; then
            echo "Invalid input format or row numbers. Your turn if over :( ."
            return
        fi

        # Exchange rows
        for ((i = 1; i <= size; i++)); do
            temp=${grid[$row1,$i]}
            grid[$row1,$i]=${grid[$row2,$i]}
            grid[$row2,$i]=$temp
        done
        
        # checking for alignments
        if [[ "$((moves % 2))" -eq 0 ]]; then
            update_scores "X" "O"
        else
            update_scores "O" "X"
        fi

        # Display the updated grid
        echo
        echo "Updated grid:"
        display_grid
        display_scores
        break
    done
}

#-------------------------------------------------------------move_4--------------------------------------------------------------
# Function to exchange columns on the grid
move_4() {
    local size=$N
    echo "Enter the columns to exchange (e.g., 'cxy' where 'x' and 'y' are column numbers):"
    read columns
    
    # Penalize players for Move 4
    if [[ "$((moves % 2))" -eq 0 ]]; then
        (( player1_score -= 1 ))
    else
        (( player2_score -= 1 ))
    fi
    
    while true; do
        # Extract column numbers from user input
        charc=${columns:0:1}
        col1=${columns:1:1}
        col2=${columns:2:1}

        # Validate column numbers
        if [[ "$charc" != "c" || "$col1" -lt 1 || "$col1" -gt "$size" || "$col2" -lt 1 || "$col2" -gt "$size" ]]; then
            echo "Invalid input format or column numbers. Your turn if over :( ."
            return
        fi

        # Exchange columns
        for ((i = 1; i <= size; i++)); do
            temp=${grid[$i,$col1]}
            grid[$i,$col1]=${grid[$i,$col2]}
            grid[$i,$col2]=$temp
        done
        
        # checking for alignments
        if [[ "$((moves % 2))" -eq 0 ]]; then
            update_scores "X" "O"
        else
            update_scores "O" "X"
        fi

        # Display the updated grid
        echo
        echo "Updated grid:"
        display_grid
        display_scores
        break
    done
}
#------------------------------------------------------------move_5-------------------------------------------------------------
# Function to exchange the positions of the player mark and the opponent mark
move_5() {
    local size=$N
    echo "Enter the rows and columns numbers of your mark & opponent mark to exchange "
    echo "(e.g., 'exyuv' where 'e' and 'x' are your row & column numbers and 'y' and 'u' your opponent row & column number):"
    read xyuv
    
    # Penalize players for Move 5
    if [[ "$((moves % 2))" -eq 0 ]]; then
        (( player1_score -= 2 ))
    else
        (( player2_score -= 2 ))
    fi
        
    while true; do
        # Extract player and opponent coordinates
        chare=${xyuv:0:1}
        row1=${xyuv:1:1}
        col1=${xyuv:2:1}
        row2=${xyuv:3:1}
        col2=${xyuv:4:1}

        # Validate coordinates
        if [[ "$chare" != "e" || "$row1" -lt 1 || "$row1" -gt "$size" || "$col1" -lt 1 || "$col1" -gt "$size" || "$row2" -lt 1 || "$row2" -gt "$size" || "$col2" -lt 1 || "$col2" -gt "$size" ]]; then
            echo "Invalid coordinates. Your turn if over :( ."
            return
        fi

        # Exchange marks
        temp=${grid[$row1,$col1]}
        grid[$row1,$col1]=${grid[$row2,$col2]}
        grid[$row2,$col2]=$temp
        
        # checking for alignments
        if [[ "$((moves % 2))" -eq 0 ]]; then
            update_scores "X" "O"
        else
            update_scores "O" "X"
        fi
        
        # Display the updated grid
        echo
        echo "Updated grid:"
        display_grid
        display_scores
        break
    done
}
#-------------------------------------------------------------main------------------------------------------------------------
# main function to control the flow of the game
main() {
    # Reset scores
    player1_score=0
    player2_score=0
    moves=0
    
    # Game initialization
    echo "Welcome to the XO Game!"
    echo "Do you want to start an empty game or load from a file? (empty/load)"
    while true; do  
        read game_option

        if [[ "$game_option" == "empty" ]]; then
            break
        elif [[ "$game_option" == "load" ]]; then
            break
        else
            echo "Invalid option. Please enter 'empty' or 'load'."
        fi
    done

    if [[ "$game_option" == "empty" ]]; then
        while true; do
            echo "Enter the size of the grid (3, 4, or 5):"
            read N
            if [[ "$N" == "3" || "$N" == "4" || "$N" == "5" ]]; then
                break
            else
                echo "Invalid grid size. Please enter 3, 4, or 5."
            fi
        done
        echo "Empty grid:"
        display_empty_grid "$N" # Display an empty grid of specified size
    elif [[ "$game_option" == "load" ]]; then
        echo "Enter the path to the file:"
        while true; do
            read file_path
            if [[ -f "$file_path" ]]; then
                break
            else
                echo "File not found. Please enter a valid file path with the extention."
            fi
        done
        echo "Grid loaded from file:"
        display_grid_from_file "$file_path"  # Display the grid loaded from the file
    fi
    
    echo
    echo "Enter player 1's name:"
    read player1
    echo "Enter player 2's name:"
    read player2
    
    
    echo "Enter the maximum number of moves:"
    while true; do
    read max_moves
      if [[ "$max_moves" -gt 2 ]]; then
        break
      else
        echo "Invalid input. Please enter a number larger than 2."
      fi
    done


    # game loop
    moves=0
    while [[ "$moves" -lt "$max_moves" ]]; do
        
        # display current player's turn
        if [[ "$((moves % 2))" -eq 0 ]]; then
            echo "$player1's turn (X)"
        else
            echo "$player2's turn (O)"
        fi

        # prompt user for move
        while true; do
            echo "Choose your move:"
            echo "1. Place mark"
            echo "2. Remove mark"
            echo "3. Exchange rows"
            echo "4. Exchange columns"
            echo "5. Exchange marks"
            echo 
            read choice

            # execute chosen move
            case $choice in
                1) move_1 && break ;;
                2) move_2 && break ;;
                3) move_3 && break ;;
                4) move_4 && break ;;
                5) move_5 && break ;;
                *) echo "Invalid choice. Please choose a number from 1 to 5." ;;
            esac
        done

        ((moves++)) # Increment moves counter
    done

        # winner based on score
        if [[ "$moves" -eq "$max_moves" ]]; then
            if [[ "$player1_score" -gt "$player2_score" ]]; then
                display_scores
                echo " "
                echo "Player $player1 wins !"
                break
            elif [[ "$player2_score" -gt "$player1_score" ]]; then 
            	display_scores
            	echo " "          
                echo "Player $player2 wins based on scores!"
                break
            else
                display_scores
                echo " "   
                echo "It's a tie!"
                break
            fi
        fi
        
    	# ask for restart or quit
    	echo "Do you want to Restart or Quit? (Restart/Quit)"
    	read des
    	while true; do
        	if [[ "$des" == "Restart" ]]; then
            		main
            		break
        	elif [[ "$des" == "Quit" ]]; then
            		exit
        	else
            		echo "Invalid choice. Please enter 'Restart' or 'Quit'."
            		read des
        	fi
        done
        	
}
# start the game
main
