#! /usr/bin/bash
LC_COLLATE=C
shopt -s extglob
export PS3="SA_DB>>"
PATH=$PATH:$(pwd)


function dbnames()
{
    if [[ $1 = [0-9]* ]]; then
        echo "Database name can't start with numbers."
        return 1

    else
        case $1 in
            +([a-zA-Z_0-9]))
                return 0
            ;;
            *)
                echo "Database name can't include special characters."
                return 1
            ;;
        esac
    fi
}

select choice in "Display available Databases." "Create Database." "Delete Database." "Display Database's content." "Connect to Database." "Exit."

do
    case $REPLY in
    
    1) #Display DBs:
        echo "Available Database: "
        ls -F ~/.SA_DB/ | grep / | tr '/' ' ' 
        echo "-----------------------------------"
    ;;
    
    2) #Create DB:
        read -r -p "Enter Database name: " dbname
        dbname=$(echo $dbname | tr ' ' '_')
        dbnames $dbname
        if (( $? == 0 )); then
            if [[ -d $HOME/.SA_DB/$dbname ]]; then
                echo "Database already exists."
                echo "-------------------------"
            else
                mkdir $HOME/.SA_DB/$dbname
                echo "Database is created successfully."
                echo "------------------------------------"
                sleep 1
            fi
        fi
    ;;

    3) #Delete DB:
        read -r -p "Enter Database name: " dbname
        dbname=$(echo $dbname | tr ' ' '_')
        dbnames $dbname
        if (( $? == 0 )); then
            if [[ -d $HOME/.SA_DB/$dbname ]]; then
                rm -r $HOME/.SA_DB/$dbname
                echo "Database $dbname is deleted."
                echo "-------------------------------"
                sleep 1
            else
                echo "Database not found."
                echo "----------------------"
            fi
        fi
    ;;

    4) #Display Content:
        read -r -p "Enter Database name: " dbname
        dbname=$(echo $dbname | tr ' ' '_')
        dbnames $dbname
        if (( $? ==0  )); then
            if [[ -d $HOME/.SA_DB/$dbname ]]; then
                echo "This Database contains the following tables $dbanme: "
                echo "--------------------------------------------------------"
                tables=$(ls -p "$HOME/.SA_DB/$dbname" | grep -v /)
                echo "$tables" | tr ' ' '\n'
            else 
                echo "Database '$dbname' not found!"
                echo "-----------------------------------"
            fi
        fi
    ;;

    5) #Connect to DB:
        read -r -p "Enter Database name: " dbname
        dbname=$(echo $dbname | tr ' ' '_')
        dbnames $dbname   
        if (( $? == 0 )); then  
            
            if [[ -d $HOME/.SA_DB/$dbname ]]; then
                cd $HOME/.SA_DB/$dbname
                echo "----------------------------------------------------------------------"  
                echo "Connecting to your database..."
                sleep 1
                source Table.sh
            else
                echo "Database '$dbname' not found!"
                echo "--------------------------------"
            fi
        else
            echo "Invalid database name."
            echo "-------------------------"
        fi
    ;;

    6) #Exit
        echo "Exiting..."
        break
    ;; 

    *)
        echo "Not a valid choice, please try again."
        echo "----------------------------------------"
    ;;

    esac
done