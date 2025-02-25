#! /usr/bin/bash
LC_COLLATE=C
shopt -s extglob
export PS3="SA_DB>>"

function dbnames()
{
    if [[ $1 = [0-9]* ]]; then
        echo "DB name can't start with numbers."
        return 1

    else
        case $1 in
            +([a-zA-Z_0-9]))
                return 0
            ;;
            *)
                echo "DB name can't contain special characters."
                return 1
            ;;
        esac
    fi
}


if [[ -d $HOME/.SA_DB ]];then
    echo "Already Exists."
else
    mkdir $HOME/.SA_DB
    echo "Folder is Created."
    sleep 2
fi


select choice in "CreateDB" "ConnectDB" "ListDB" "RemoveDB" "Exit"
do
    case $REPLY in
    1) #Create
        read -r -p "Enter Data Base Name: " dbname
        dbname=$(echo $dbname | tr ' ' '_')
        dbnames $dbname
        if (( $? == 0 )); then
            if [[ -d $HOME/.SA_DB/$dbname ]]; then
                echo "Data Base already exists."
            else
                mkdir $HOME/.SA_DB/$dbname
                echo "Data Base is created successfully."
                sleep 1
            fi
        fi

    ;;
    2) #Connect
        read -r -p "Enter Data Base Name: " dbname
        dbname=$(echo $dbname | tr ' ' '_')
        dbnames $dbname
        if (( $? == 0 )); then
            if [[ -d $HOME/.SA_DB/$dbname ]]; then
                cd $HOME/.SA_DB/$dbname
                echo "Data Base already exists."
                sleep 1
                source table.sh $dbname
            else
                mkdir $HOME/.SA_DB/$dbname
                echo "Data Base is created successfully."
                
            fi
        fi
    ;;
    3) #List
        ls -F ~/.SA_DB/ | grep / | tr '/' ' ' 
    ;;
    4) #Remove  
        read -r -p "Enter Data Base Name: " dbname
        dbname=$(echo $dbname | tr ' ' '_')
        dbnames $dbname
        if (( $? == 0 )); then
            if [[ -d $HOME/.SA_DB/$dbname ]]; then
                rm -r $HOME/.SA_DB/$dbname
                echo "Data Base $dbname is removed."
                sleep 1
            else
                echo "Data Base not found."
            fi
        fi
    ;;
    5) #Exit

    ;; 

    *)
        echo "Not valid choice, please try again."
    ;;
    esac
done