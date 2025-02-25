#! /usr/bin/bash
LC_COLLATE=C
shopt -s extglob
export PS3="$1 >>"

function tablenames()
{
    if [[ $1 = [0-9]* ]]; then
        echo "Table name can't start with numbers."
        return 1
    else
        case $1 in
            +([a-zA-Z_0-9]))
                return 0
            ;;
            *)
                echo "Table name can't include special characters."
                return 1
            ;;
        esac
    fi
}

select choice in  "Display available tables." "Create Table." "Insert in a Table." "Display a Table." "Display table's information." "Update on table." "Delete Table." "Exit."
do
    case $REPLY in

    1) #List Tables:
        echo "Available Tables: "
        if [[ -d "$HOME/.SA_DB/$dbname" ]]; then
            # List all files (tables) in the database directory
            tables=$(ls -p "$HOME/.SA_DB/$dbname" | grep -v /)
            if [[ -z "$tables" ]]; then
                echo "No tables found in the database '$dbname'."
                echo "-------------------------------------------"
            else
                echo "$tables"
                echo "-------------------------"
            fi
        else
            echo "Database '$dbname' does not exist."
            echo "----------------------------------"
        fi
    ;;

    2) #Create Table:
        read -r -p "Enter table name: " tablename
        tablename=$(echo $tablename | tr ' ' '_')
        tablenames $tablename
        if (( $? == 0 )); then
            if [[ -d $HOME/.SA_DB/$dbname/$tablename ]]; then
                echo "Table already exists."
                echo "----------------------"
            else
                touch $HOME/.SA_DB/$dbname/$tablename
                
                # Build the table
                read -r -p "Enter the number of columns: " nocol
                if [[ ! $nocol =~ ^[0-9]+$ ]]; then
                    echo "Invalid number of columns."
                    echo "----------------------------"
                    continue
                fi

                Names=""
                Constraints=""

                for (( i = 1; i <= nocol; i++ )); 
                do
                    echo "Enter details for column $i:"
                    echo "------------------------------"
                    
                    # Ask for unique name 
                    while true; 
                    do
                        read -r -p "Enter column name: " colname
                        if [[ $Names != *"$colname"* ]]; then
                            Names+="$colname,"  
                            break  
                        else
                            echo "Please choose a unique name."
                            echo "------------------------------"
                        fi
                    done

                    while true; 
                    do
                        read -r -p "Choose a type from (String, Integer): " coltype
                        coltype_lower=$(echo "$coltype" | tr '[:upper:]' '[:lower:]')
                        if [[ $coltype_lower == "string" || $coltype_lower == "integer" ]]; then
                            coltype=$coltype_lower
                            break
                        else
                            echo "Invalid type. Please choose 'String' or 'Integer'."
                            echo "----------------------------------------------------"
                        fi
                    done

                    # Column constraints
                    while true; 
                    do
                        read -r -p "Choose a constraint from (PK, FK, Unique, None).: " colconst
                        colconst_upper=$(echo "$colconst" | tr '[:lower:]' '[:upper:]') 
                        if [[ $colconst_upper == "PK" || $colconst_upper == "FK" || $colconst_upper == "UNIQUE" || $colconst_upper == "NONE" ]]; then
                            colconst=$colconst_upper 
                            break
                        else
                            echo "Invalid constraint. Please choose 'PK', 'FK', 'Unique' or 'None'."
                            echo "--------------------------------------------------------------------"
                        fi
                    done

                    # Append column types and constraints
                    Constraints+="$coltype:$colconst,"
                done

                # Save content
                echo "$Names" > $HOME/.SA_DB/$dbname/$tablename
                echo "$Constraints" >> $HOME/.SA_DB/$dbname/$tablename

                echo "Table '$tablename' is created successfully."
                echo "-----------------------------------------------"
                sleep 1
            fi
        fi
    ;;

    3) #Insert in table:
        read -r -p "Enter table name: " tablename
        tablename=$(echo $tablename | tr ' ' '_')
        tablenames $tablename
        if (( $? == 0 )); then
            if [[ -f $HOME/.SA_DB/$dbname/$tablename ]]; then
                IFS=',' read -r -a columns <<< "$(head -n 1 $HOME/.SA_DB/$dbname/$tablename)"
                IFS=',' read -r -a constraints <<< "$(sed -n '2p' $HOME/.SA_DB/$dbname/$tablename)"

                read -r -p "Enter number of rows to add: " rows
                if [[ ! $rows =~ ^[0-9]+$ ]]; then
                    echo "Invalid number of rows."
                    continue
                fi

                for (( row = 1; row <= rows; row++ )); 
                do
                    echo "Insert in row number $row."
                    data=""
                    for (( col = 0; col < ${#columns[@]}; col++ ));
                    do
                        while true;
                        do
                            read -r -p "Enter value for column ${columns[col]}: " value
                            if [[ ${constraints[col]%%:*} == "integer" && ! $value =~ ^[0-9]+$ ]]; then
                                echo "Invalid value. Please enter an integer."
                            else
                                break
                            fi
                        done
                        data+="$value,"
                    done
                    # Remove the trailing comma and append the row to the table
                    data=${data%,}
                    echo "$data" >> $HOME/.SA_DB/$dbname/$tablename
                    echo "$row row is inserted successfully."
                    echo "-------------------------------------"
                done
            else 
                echo "Table $tablename doesn't exist."
                echo "----------------------------------"
            fi
        fi
    ;;

    4) #Display a Table:
        read -r -p "Enter table name: " tablename
        tablename=$(echo $tablename | tr ' ' '_')
        tablenames $tablename
        if (( $? == 0 )); then
            if [[ -f $HOME/.SA_DB/$dbname/$tablename ]]; then
                echo "Table '$tablename':"
                echo "------------------------"

                # Read column names from the first line of the file
                IFS=',' read -r -a columns <<< "$(head -n 1 $HOME/.SA_DB/$dbname/$tablename)"

                # Display the table header
                for col in "${columns[@]}"; 
                do
                    printf "| %-10s " "$col"
                done
                echo "|"
                echo "-------------------------"

                # Display the table rows
                tail -n +3 $HOME/.SA_DB/$dbname/$tablename | while IFS= read -r line; 
                do
                    IFS=',' read -r -a row <<< "$line"
                    for cell in "${row[@]}"; 
                    do
                        printf "| %-10s " "$cell"
                    done
                    echo "|"
                done
            else
                echo "Table '$tablename' does not exist."
            fi    
        fi
    ;;

    5) #Display table's information:
        read -r -p "Enter table name: " tablename
        tablename=$(echo $tablename | tr ' ' '_')
        tablenames $tablename
        if (( $? == 0 )); then
            if [[ -f $HOME/.SA_DB/$dbname/$tablename ]]; then
                echo "Table '$tablename' information:"
                echo "----------------------------------"

                # Read column names from the first line of the file
                IFS=',' read -r -a columns <<< "$(head -n 1 $HOME/.SA_DB/$dbname/$tablename)"

                # Read column types and constraints from the second line of the file
                IFS=',' read -r -a constraints <<< "$(sed -n '2p' $HOME/.SA_DB/$dbname/$tablename)"

                # Display column name, type, and constraint for each column
                for (( i = 0; i < ${#columns[@]}; i++ )); do
                    echo "Column $((i+1)):"
                    echo "  Name: ${columns[i]}"
                    IFS=':' read -r -a type_constraint <<< "${constraints[i]}"
                    echo "  Type: ${type_constraint[0]}"
                    echo "  Constraint: ${type_constraint[1]}"
                    echo "--------------------------------------"
                done
            else
                echo "Table '$tablename' does not exist."
            fi    
        fi
    ;;

    6) #Update table:
        read -r -p "Enter table name to edit: " tablename
        tablename=$(echo $tablename | tr ' ' '_')
        tablenames $tablename
        if (( $? == 0 )); then
            if [[ -f $HOME/.SA_DB/$dbname/$tablename ]]; then
                echo "Table '$tablename':"
                echo "--------------------------"

                IFS=',' read -r -a columns <<< "$(head -n 1 $HOME/.SA_DB/$dbname/$tablename)"

                # Display the table rows
                for col in "${columns[@]}"; 
                do
                    printf "| %-10s " "$col"
                done
                echo "|"
                echo "-------------------------"

                # Display the table rows
                rows=()
                while IFS= read -r line; 
                do
                    rows+=("$line")
                done < <(tail -n +3 $HOME/.SA_DB/$dbname/$tablename)

                for (( i = 0; i < ${#rows[@]}; i++ )); 
                do
                    IFS=',' read -r -a row <<< "${rows[i]}"
                    for cell in "${row[@]}"; 
                    do
                        printf "| %-10s " "$cell"
                    done
                    echo "|"
                done

                # Ask for the column to edit
                while true; do
                    read -r -p "Enter the column name to edit: " colname
                    if [[ " ${columns[@]} " =~ " ${colname} " ]]; then
                        break
                    else
                        echo "Invalid column name. Please choose from: ${columns[@]}"
                        echo "---------------------------------------------------------"
                    fi
                done

                # Ask for the row number to edit
                while true; 
                do
                    read -r -p "Enter the row number to edit: " rownum
                    if [[ $rownum =~ ^[0-9]+$ && $rownum -ge 1 && $rownum -le ${#rows[@]} ]]; then
                        break
                    else
                        echo "Invalid row number. Please enter a number between 1 and ${#rows[@]}."
                        echo "-----------------------------------------------------------------------"
                    fi
                done

                # Ask for the new value
                read -r -p "Enter the new value for column '$colname' in row $rownum: " newvalue

                # Update the row
                IFS=',' read -r -a row <<< "${rows[$((rownum-1))]}"
                colindex=$(echo ${columns[@]} | tr ' ' '\n' | grep -n "^${colname}$" | cut -d: -f1)
                row[$((colindex-1))]=$newvalue
                rows[$((rownum-1))]=$(IFS=','; echo "${row[*]}")

                # Write the updated rows back to the file
                {
                    head -n 2 $HOME/.SA_DB/$dbname/$tablename
                    printf "%s\n" "${rows[@]}"
                } > $HOME/.SA_DB/$dbname/$tablename.tmp
                mv $HOME/.SA_DB/$dbname/$tablename.tmp $HOME/.SA_DB/$dbname/$tablename

                echo "Row $rownum updated successfully."
                echo "------------------------------------"
            else
                echo "Table '$tablename' does not exist."
                echo "-------------------------------------"
            fi
        fi
    ;;

    7) #Delete Table:
        read -r -p "Enter table name: " tablename
        tablename=$(echo $tablename | tr ' ' '_')
        tablenames $tablename
        if (( $? == 0 )); then
            if [[ -f $HOME/.SA_DB/$dbname/$tablename ]]; then
                rm $HOME/.SA_DB/$dbname/$tablename
                echo "Table '$tablename' is deleted."
                echo "---------------------------------"
                sleep 1
            else
                echo "Table '$tablename' does not exist."
                echo "------------------------------------"
            fi
        fi
    ;;

    8) #Exit
        echo "Exiting..."
        break
    ;; 

    *)
        echo "Not a valid choice, please try again."
    ;;

    esac
done