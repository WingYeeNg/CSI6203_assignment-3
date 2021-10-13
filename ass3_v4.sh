#!/bin/bash

scount=0

while true; do # using while loop to keep the script running or to break out of it
  
  # use if statement to account for first search or subsequent search
  if [[ $scount = 0 ]]; then 
     read -p "Hi, enter [1] to search or [2] to exit: "
  else # if user runs the script more than once
    echo -e "\n"
    read -p "Enter [1] to search again or [2] to exit: "
  fi
  
  # use if statement to test user's reply, break out of loop if [2] is selected
  if [[ $REPLY = 2 ]]; then 
    break

   elif [[ $REPLY = 1 ]]; then
    clear
   
     # declare array of files named serserv_acc_log.+csv in the working directory and list them out
     unset logs # clear the search history to avoid duplicated search result
     declare -a logs 
     patt="serv_acc_log.+csv$" 
     mennum=1

       # find all matching files in working directory with for loop
       for file in ./*; do
         if [[ $file =~ $patt ]]; then
         logs+=($(basename $file))
         fi
       done

   # display the amount of files found; List them out with a number starting from 1
   count=${#logs[*]}
   echo -e "The logs array contains $count files.\n"

       for file in "${logs[@]}"; do
           echo -e "$mennum $file"
           ((mennum++))
       done


   # prompt user to select a file listed in the menu
   echo -e "\n"
   read -p "Enter the number of the file in the menu above you wish to search [1,2,3,4 or 5]. Or [6] for searching all files: " sel
   
   # for case statement option[6], use grep to output all files to meet Advanced Functional Requirements 2
    case $sel in
     [1-5]) fileopt=${logs[$sel-1]} # for option 1 to 5, use grep to analayze the representing file
         grep "suspicious$" $fileopt > tempfile.csv;; # output only the contents classed suspicious from the selected file & output the content, for further action
     6)   fileopt=${logs[*]} # for option 6, use grep to analayse  all files found
         grep "suspicious$" $fileopt > tempfile.csv;;# output only the contents classed suspicious from all matching files, for further action
     *)   echo "Invaild selection, exiting programme." && exit 1;;
    esac

    clear
    echo -e "You have entered $fileopt\n"

   # prompt user to select a search field listed in the menu
   echo -e "Search Fields:\n1 PROTOCOL\n2 SRC IP\n3 SRC PORT\n4 DEST IP\n5 DEST PORT\n6 PACKET\n7 BYTES\n"
   read -p 'Enter the number of field in the menu above you wish to search [1,2,3,4,5,6 or 7]: ' selfield

   # use function to encapsulate commands for saving the specified file name 
   savefile() {
   filename1=$(date +%d%m%Y_%T) # with 2 provided options, files shall be named after current date& time to create unique file names
   filename2=$(date +%T_%d%m%Y) 
   
   # as 2 formats are to be chosen, example of each format is provided for easy understand
   echo -e "\n"
   echo -e "File Name Formats:\n1 date_time i.e.[30092021_15:39:07]\n2 time_date i.e. [15:39:07_30092021]\n"
   read -p 'Enter the number of format in the menu above you wish to name your output file [1 or 2]: ' selffilename #prompt user to choose from option 1 or 2 to name his file

    # use case function, rename the output search result with mv command according to user's choice of format
    # remove the output file of grep 'tempfile.csv' as it shall be no longer needed
    case $selffilename in
      1) mv tempresult.csv $filename1.csv && rm tempfile.csv && echo -e "\nThe output file $filename1.csv is saved.\n" && ls;; 
      2) mv tempresult.csv $filename2.csv && rm tempfile.csv && echo -e "\nThe output file $filename2.csv is saved.\n" && ls;; 
      *) mv tempresult.csv $filename1.csv && rm tempfile.csv && echo -e "\nInvalid input. The output file is saved as $filename1.csv anyway.\n" && ls;; #otherwise, do the task in option 1's way to avoid output files being overlapped
    esac
   }


   # use case statement and function listed above to run the whole solution
   case $selfield in
     # for protocols search, prompt user to select a specified protocol
     1) echo -e "\n"
        echo -e "Protocols:\n1 TCP\n2 UDP\n3 ICMP\n4 GRE\n" 
        read -p 'Enter the number of key protocol above you wish to search [1,2,3 or 4]: ' selprotocol
        
        # use case function in respond to user's choice, with awk to search for keywords e.g. TCP. Print the matching contents out in the columns. Output the search result and display to terminal
        case $selprotocol in
         1) awk 'BEGIN {FS=","; NR>1} $3 ~/TCP/ { printf "%-5s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9 }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
         2) awk 'BEGIN {FS=","; NR>1} $3 ~/UDP/ { printf "%-3s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9 }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
         3) awk 'BEGIN {FS=","; NR>1} $3 ~/ICMP/ { printf "%-4s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9 }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
         4) awk 'BEGIN {FS=","; NR>1} $3 ~/GRE/ { printf "%-3s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9 }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
         *) echo "Invalid selection. Exit Program." && exit 1;;
        esac
        savefile;; # call the function out to perform file saving task
     
     # for source ip, prompt the user to enter a code for searching
     2) read -p 'Enter the code you wish to search: ' selsrcip
        # Use If statement to print the result when content matches with input code in either upper/ lower case, to make the search case insensitive
        # With awk, print the search result out in columns; Output and display the result to terminal
        awk 'BEGIN {FS=","} 
        NR>1 {
               if ( tolower($4) ~/'"$selsrcip"'/ || toupper($4) ~/'"$selsrcip"'/ )
               { 
               printf "%-6s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
               } 
             }' < tempfile.csv > tempresult.csv && cat tempresult.csv
        savefile;;
     
     # for source port, prompt the user to enter a port for searching. With awk, print the matching result to the terminal and also save the result
     3) read -p 'Enter the SRC PORT you wish to search: ' selsrcport
        awk 'BEGIN {FS=","; NR>1} $5 ~ /'$selsrcport'/ { printf "%-5s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9 }' < tempfile.csv > tempresult.csv && cat tempresult.csv
        savefile;;
     
     # for destination IP, prompt the user to enter a value for searching
     4) read -p 'Enter the code you wish to search: ' seldestip
        # Use if statement to print the result when content matches with input code in upper/ lower case, to make the search case insensitive. With awk, print the related contents out in the alignment; Then, save the search result and also display to terminal
        awk 'BEGIN {FS=","} 
         NR>1 {
               if ( tolower($6) ~/'"$seldestip"'/ || toupper($6) ~/'"$seldestip"'/ )
               { 
               printf "%-6s %-15s %-10s %-15s %-7s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
               } 
              }' < tempfile.csv > tempresult.csv && cat tempresult.csv
        savefile;;
     
     # for destination port, prompt the user to enter a port for searching. With awk, output and display the result to terminal
     5) read -p 'Enter the DEST PORT you wish to search: ' seldestport
        awk 'BEGIN {FS=","; NR>1} $7 ~ /'$seldestport'/ { printf "%-5s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9 }' < tempfile.csv > tempresult.csv && cat tempresult.csv
        savefile;;
     
     # for packets, prompt user to enter a number for searching, then prompt user to select search criteria with case function e.g. -gt/-lt/!-eq to run the search
     6) read -p "Enter a value you wish to search: " value
        read -p "Choose to search 1/ greater than, 2/ less than, 3/ equal to or 4/ not equal to $value [1,2,3 or 4]: " range

        cct=$value
        
        # in case statement, use awk searching for all input value with '>' '<' and '=' operators; 
        # to meet Advanced Functional Requirements 3, sum all the matching values up& display in last row with awk
        case $range in
         1) awk ' BEGIN {FS=","; ttlpackets=0; ttlbytes=0} 
            NR>1 {
                   if ( $8 > '"$value"' ) 
                   { 
                    ttlpackets=ttlpackets+$8
                    printf "%-6s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
                   } 
                  }
            END { print "Total packets for all matching rows is ", ttlpackets }' < tempfile.csv > tempresult.csv && cat tempresult.csv;; 
         2) awk ' BEGIN {FS=","; ttlpackets=0; ttlbytes=0} 
            NR>1 {
                   if ( $8 < '"$value"' )
                   { 
                    ttlpackets=ttlpackets+$8
                    printf "%-6s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
                   } 
                 }
            END { print "Total packets for all matching rows is ", ttlpackets }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
         3) awk ' BEGIN {FS=","; ttlpackets=0; ttlbytes=0} 
            NR>1 {
                   if ( $8 == '"$value"' )
                   { 
                    ttlpackets=ttlpackets+$8
                    printf "%-6s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
                   } 
                  }
             END { print "Total packets for all matching rows is ", ttlpackets }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
         4) awk ' BEGIN {FS=","; ttlpackets=0; ttlbytes=0} 
            NR>1 {
                  if ( $8 != '"$value"' )
                   { 
                   ttlpackets=ttlpackets+$8
                   printf "%-6s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
                   } 
                 }
            END { print "Total packets for all matching rows is ", ttlpackets }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
         *) echo "Invalid input. Exit programme." && exit 1;;
       esac
       savefile;;
       
     # for bytes, prompt user to enter a number for searching, then prompt user to select search criteria with case function
     7)  read -p "Enter a value you wish to search: " bvalue
         read -p "Choose to search 1/ greater than, 2/ less than, 3/ equal to or 4/ not equal to $value [1,2,3 or 4]: " brange
         
         # in case statement, use awk searching for all input value with '>' '<' and '=' operators; 
         # to meet Advanced Functional Requirements 3, sum all the matching values up& display in last row with awk
         case $brange in
          1) awk ' BEGIN {FS=","; ttlpackets=0; ttlbytes=0} 
             NR>1 {
                   if ( $9 > '"$bvalue"' )
                   { 
                     ttlbytes=ttlbytes+$9
                     printf "%-6s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
                    } 
                  }
             END { print "Total size for all matching rows is ", ttlbytes, " bytes." }' < tempfile.csv > tempresult.csv && cat tempresult.csv;; 
          
          2) awk ' BEGIN {FS=","; ttlpackets=0; ttlbytes=0} 
             NR>1 {
                   if ( $9 < '"$bvalue"' )
                   { 
                    ttlbytes=ttlbytes+$9
                    printf "%-6s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
                   } 
                  }
             END { print "Total size for all matching rows is ", ttlbytes, " bytes." }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
          
          3) awk ' BEGIN {FS=","; ttlpackets=0; ttlbytes=0} 
             NR>1 {
                   if ( $9 = '"$bvalue"' )
                   { 
                    ttlbytes=ttlbytes+$9
                    printf "%-6s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
                   } 
                  }
             END { print "Total size for all matching rows is ", ttlbytes, " bytes." }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
          
          4) awk ' BEGIN {FS=","; ttlpackets=0; ttlbytes=0} 
             NR>1 {
                   if ( $9 != '"$bvalue"' )
                   { 
                    ttlbytes=ttlbytes+$9
                    printf "%-6s %-15s %-10s %-15s %-10s %-5s %-10s \n", $3, $4, $5, $6, $7, $8, $9
                   } 
                  }
             END { print "Total size for all matching rows is ", ttlbytes, " bytes." }' < tempfile.csv > tempresult.csv && cat tempresult.csv;;
          
          *) echo "Invalid selection, exiting programme." && exit 1;; # when user input anything out of the menu, exit the programme
          esac
        savefile;;
     
     *) echo "Invalid selection, exiting program." && exit 1;; # when user input anything out of the menu, exit the programme
   esac

  else
   echo "Invalid selection, exiting programme." && exit 1

 fi 

 ((scount++)) 

done

exit 0