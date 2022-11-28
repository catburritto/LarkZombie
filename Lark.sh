#!/bin/bash
# Lark.sh
NOCOLOR=$(tput sgr0)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
BLUE=$(tput setaf 4)
RED=$(tput setaf 1)
BLINK=$(tput blink)
BOLD=$(tput bold)
function printWin() {
	echo "${GREEN}Congratulations $userName YOU SURVIVED"
	echo "${BLUE}The military has rescued you from the ruins and took you to a shelter."
	echo "${BLUE}You no longer have to worry about resources and the apocalyptic world"
}

function printLose() {
	echo "${RED}Game over $userName YOU DIED"
	echo "You were killed before the military could rescue you"
}


clear

function save() {
	echo "$storageCount" > $saveFile
	echo "$suppliesCount" >> $saveFile
	echo "$dayCount" >> $saveFile
	echo "$chance" >> $saveFile
	echo "$survivorLoc" >> $saveFile
	echo "$userName" >> $saveFile
	echo "${storageIntArray[*]}" >> $saveFile
	echo "${storageArray[*]}" >> $saveFile
	echo "$medsCount" >> $saveFile
	echo "$survivor9SuppliesCount" >> $saveFile
	echo "$missionTask" >> $saveFile
	echo "$suppliesCollected" >> $saveFile
	echo "$previousSuppliesCount" >> $saveFile
	echo "$dayComplete" >> $saveFile
}

function getSave() {
	storageCount=$( sed -n '1'p $saveFile )
	suppliesCount=$( sed -n '2'p $saveFile )
	dayCount=$( sed -n '3'p $saveFile )
	chance=$( sed -n '4'p $saveFile )
	survivorLoc=$( sed -n '5'p $saveFile )
	userName=$( sed -n '6'p $saveFile )
	storageIntArray=$( sed -n '7'p $saveFile )
	storageArray=$( sed -n '8'p $saveFile )
	medsCount=$( sed -n '9'p $saveFile )
	survivor9SuppliesCount=$( sed -n '10'p $saveFile )
	missionTask=$( sed -n '12'p $saveFile )
	suppliesCollected=$( sed -n '13'p $saveFile )
	previousSuppliesCount=$( sed -n '14'p $saveFile )
	dayComplete=$( sed -n '15'p $saveFile )

	IFS=' ' read -ra storageIntArray <<< "$storageIntArray"
	IFS=' ' read -ra storageArray <<< "$storageArray"
	if [ "$dayComplete" == 0 ]; then
		(( dayCount = $dayCount + 1 ))
	fi
}

function getLoc() {
	local currentDir="$1"
	local sizeMax="${#currentDir}"
	if [ "$currentDir" == "$PWD" ]; then
		local sizeMin="$(expr ${#currentDir} - 28)"
	else
		local sizeMin="$(expr ${#currentDir} - 26)"
	fi
	currentDir="${currentDir:$sizeMin:$sizeMax}"
	currentDir=($(echo $currentDir | tr -d -c 0-9))
	echo "$currentDir"
	if [ "${#currentDir}" == 0 ]; then
		currentDir="0001"
	elif [ "${#currentDir}" == 1 ]; then
		(( currentDir=$currentDir * 1000 + 1 ))
	elif [ "${#currentDir}" == 2 ]; then
		(( currentDir=$currentDir * 100 + 1 ))
	elif [ "${#currentDir}" == 3 ]; then
		(( currentDir=$currentDir * 10 + 1 ))
	fi
	survivorLoc=$currentDir
}

function goToSurvivorLoc() {
	BuildingIntDef="${survivorLoc:0:1}"
	RoomAIntDef="${survivorLoc:1:1}"
	RoomBIntDef="${survivorLoc:2:1}"
	RoomIntBDef="${survivorLoc:3:1}"
	if [ "$BuildingIntDef" == 0 ]; then
		cd "$prefix/city"
	elif [ "$RoomAIntDef" ==  0 ]; then
		cd "$prefix/city/building$BuildingIntDef"
	elif [ "$RoomBIntDef" == 0 ]; then
		cd "$prefix/city/building$BuildingIntDef/room$RoomAIntDef"
	else
		cd "$prefix/city/building$BuildingIntDef/room$RoomAIntDef/room$RoomBIntDef"
	fi
}

function scavenge() {
	clear
	echo -e "${BLINK}searching...${NORMAL}"
	sleep 2
	echo -e "${BLINK}...${NORMAL}"
	sleep 2
	echo -e "${BLINK}searching...${NORMAL}"
	sleep 2
	echo -e "${BLINK}...${NORMAL}"
	clear
}

function scareSpecific() {
	if [ -z "$1" ]; then
		getLoc $PWD
	else
		getLoc $1
	fi
	local tempVal=$survivorLoc
	local BuildingIntDef="${tempVal:0:1}"
	local RoomAIntDef="${tempVal:1:1}"
	local RoomBIntDef="${tempVal:2:1}"
	local SuppliesIntDef="${tempVal:3:1}"
	local flag=0
	r=0

	for (( r ; r < $storageCount ; r++ )); do
		tempValDef="${storageIntArray[$r]}"
		BuildingInt="${storageIntArray[$r]:0:1}"
		RoomAInt="${storageIntArray[$r]:1:1}"
		RoomBInt="${storageIntArray[$r]:2:1}"
		SuppliesInt="${storageIntArray[$r]:3:1}"

		if [ "$tempVal" != "$tempValDef" ] && [ "$SuppliesInt" != 0 ]; then
	    	if [ "$BuildingIntDef" == "$BuildingInt" ]; then
    			if [ "$RoomAIntDef" == "$RoomAInt" ]; then
    				if [ "$SuppliesIntDef" != 0 ]; then
    					(( storageIntArray[$r] = ${storageIntArray[$r]} - 1 ))
    		    		flag=1
    		    		echo "It looks like one of the areas is too dangerous to keep looking for supplies." > "${storageArray[$r]}"
	    	    	fi
		    	elif [ "$RoomBIntDef" != "$RoomBInt" ] && [ "$RoomBIntDef" != 0 ] && [ "$RoomAIntDef" != 0 ]; then
    				if [ "$SuppliesIntDef" != 0 ]; then
    					(( storageIntArray[$r] = ${storageIntArray[$r]} - 1 ))
    					flag=1
    					echo "It looks like one of the areas is too dangerous to keep looking for supplies." > "${storageArray[$r]}"
		    		fi
    			elif [ "$RoomAIntDef" == "$RoomAInt" ] && [ "$RoomBIntDef" == 0 ]; then
    				(( storageIntArray[$r] = ${storageIntArray[$r]} - 1 ))
    				flag=1
	    			echo "It looks like one of the areas is too dangerous to keep looking for supplies." > "${storageArray[$r]}"
	    		elif [ "$RoomAIntDef" == 0 ]; then
    				(( storageIntArray[$r] = ${storageIntArray[$r]} - 1 ))
    				flag=1
	    			echo "It looks like one of the areas is too dangerous to keep looking for supplies." > "${storageArray[$r]}"
	    		fi
    		fi
		fi
	done
	if [ "$flag" == 1 ]; then
 		echo "You hear the shuffling of footsteps to a room in the building. Better not go there..."
	fi
}

function commandCase() {
	echo
	echo "Enter a command in the format COMMAND [FLAG] PARAMETER (s to skip):"
	read -p "$PWD > " inputCom ComArg1 ComArg2
	case "$inputCom" in
		"cd")
    		if [ -d $ComArg1 ] && [ -x $ComArg1 ]; then
    			echo "Travelling to $ComArg1..."
	    		cd $ComArg1
	    		getLoc $PWD
    		else 
    			echo "$ComArg1 is not a directory.."
    			echo
	    		scareSpecific
    		fi
    		commandCase
    	;;
    	"ls")
    	    if [ "$ComArg1" == "-a" ] || [ "$ComArg1" == "-la" ] || [ "$ComArg1" == "-al" ] || [ -d $ComArg1 ] || [ -f $ComArg1 ]; then
	    		if [ -d $ComArg2 ] || [ -f $ComArg2 ] || [ -z $ComArg2 ];then
    				ls $ComArg1 $ComArg2
    			else
    				echo "$ComArg2 is not a file or directory..."
	    			echo
    				scareSpecific
    			fi
	   		else 
    			echo "$ComArg1 is not a valid argument..."
	    		echo
		    	scareSpecific
    		fi
    		commandCase
	    ;;
    	"cat")
			pathVar1=$( echo "$ComArg1" | awk -F'/' '{print $1}' )
			pathVar2=$( echo "$ComArg1" | awk -F'/' '{print $2}' )
			pathVar3=$( echo "$ComArg1" | awk -F'/' '{print $3}' )
			pathVar4=$( echo "$ComArg1" | awk -F'/' '{print $4}' )
			if [ -f $ComArg1 ] && [ ! -z $ComArg1 ]; then
				cat $ComArg1
				echo
        		suppliesTestVar=$( cat $ComArg1 )
				if [ $suppliesTestVar == "SUPPLIES!" ]; then
          			echo "You found supplies!" > $ComArg1
          			(( suppliesCount = $suppliesCount + 1 ))
          			echo $ComArg1
          			local catBalls=$( getLoc $ComArg1 )
                	for ((i = 1 ; i <= $storageCount ; i++)); do
                  		if [ "$survivorLoc" == "${storageIntArray[$i]}" ]; then
                    		storageIntArray[$i]=$(( storageIntArray[$1] - 1 ))
                    		echo "yes"
                		fi
              		done
					return
				else
					echo "You found $suppliesTestVar!" > $ComArg1
					return
        		fi
			elif [ -z $ComArg1 ]; then
				echo "No argument passed to cat..."
				echo
				scareSpecific
			elif [ ! -z $ComArg1 ]; then
				if [ -f "$pathVar1/$pathVar2/$pathVar3/$pathVar4" ] && [ ! -z $pathVar4 ]; then
            		echo "test1"
					echo
					scareSpecific $ComArg1
				elif [ -f "$pathVar1/$pathVar2/$pathVar3" ] || [ -d "$pathVar1/$pathVar2/$pathVar3" ] && [ ! -z $pathVar3 ]; then
            		echo "test2"
					echo
					scareSpecific $ComArg1
          		elif [ -f "$pathVar1/$pathVar2" ] || [ -d "$pathVar1/$pathVar2" ] && [ ! -z $pathVar2 ]; then
            		echo "test3"
					echo
					scareSpecific $ComArg1
				elif [ -f $pathVar1 ] || [ -d $pathVar1 ] && [ ! -z $pathVar1 ]; then
            		echo "test4"
					echo
					scareSpecific $ComArg1
         		else
         			echo "$ComArg1 is not a viable pathname or file..."
					echo
					scareSpecific
				fi
			else 
				echo "$ComArg1 is not a file..."
				echo
				scareSpecific
			fi
			commandCase
		;;
		"chmod")
			if [ "$ComArg1" == "+rwx" ] || [ "$ComArg1" == "+wrx" ] || [ "$ComArg1" == "+xrw" ] || [ "$ComArg1" == "+rxw" ] || [ "$ComArg1" == "+xwr" ] || [ "$ComArg1" == "+wxr" ] || [ "$ComArg1" == "+x" ] || [ "$ComArg1" == "+w" ] || [ "$ComArg1" == "+r" ] || [ "$ComArg1" == "+rw" ]  || [ "$ComArg1" == "+wr" ] || [ "$ComArg1" == "+xw" ] || [ "$ComArg1" == "+wx" ]  || [ "$ComArg1" == "+rx" ]  || [ "$ComArg1" == "+xr" ]; then
				if [ -d $ComArg2 ] || [ -f $ComArg2 ]; then
					chmod $ComArg1 $ComArg2
				fi
			else
				echo "$ComArg1 and/or $ComArg2 are not valid arguments..."
				echo
				scareSpecific
			fi
			commandCase
		;;
		s|S|"Skip")
		;;
		q|Q)
			exit
		;;
		*)
			echo "$inputCom is not a valid command..."
			echo
			scareSpecific
			commandCase
		;;
	esac
}

function scareRandom() {
	if [ "$storageCount" == 0 ]; then
		break
	fi
	num=$((1 + RANDOM % 3)) # Picks a random number between 1 and 3 to see if a storage is scared off
	if [ 2 -eq $num ]; then
		randnum=$((1 + RANDOM % $storageCount))
		echo "It looks like one of the areas is too dangerous to keep looking for supplies." > "${storageArray[$randnum]}"
		echo "You decide it's best to scavenge elsewhere"
		storageIntArray[$randnum]=$((storageIntArray[$randnum] - 1))
	else
		echo "The area looks safe enough to scavenge!"
	fi
}

function cont() {
	echo
	read -p "Press enter to continue..."
}

function kyle() {
	local option
	local answer
	local donate
	echo
	echo "Hello $userName, how can I help you?"
	select option in Talk Help Donate Leave Quit; do
        	case "$option" in
        	"Talk")
				echo "Its been rough out here, glad we have been able to make this nice little camp to call home."
				echo "By the way my name is Kyle, I am the leader of this camp."
				break 2
			;;
			"Help")
				echo "I will tell you about the buildings we need to scavange."
				read -p "What building do you want to know about? (1-5), 0 to leave, q to quit): " answer
				echo
				case "$answer" in
					1) 
							echo "Building 1 is a grocery story that could have food and water for the survivors here"
							echo "This is a low risk building"
							break 2
							;;
					
					2)
							echo "Building 2 is a school."
							echo "This is a low/medium risk area"
							break 2
							;;
					3)
						
							echo "Building 3 is a Hardware store. Here you can find many items to fortify the camp."
							echo "This is a medium risk area"
							break 2
							;;
						
						
					
					4)
						
							echo "Building 4 is a Hospital. THe hospital has important medicine and aid." 
							echo "This is a medium/high risk area"
							break 2
							;;
					5)
						
							echo "Building 5 is a prison. The prison could have very important supplies."
							echo "This is a high risk area"
							break 2
							;;
					
					0|L)
						echo "Alright, stay safe out there. Hope to see you back in once peice."
						break 2
					;;
					q|Q)
						exit
					;;
					*)
						echo "Ok just let me know if you need anything!"
						;;
					esac
				;;
			"Donate")
				echo "Oh. Thank you for these supplies"
				read -p "If your're willing, I can take it off your hands. (y/n) " donate
				case "$donate" in 
					y|Y)
						echo "Thank you so much $userName!"
						if [ $suppliesCount -gt 0 ]; then
							(( suppliesCount = $suppliesCount - 1 ))
							chance=1
						else
							chance=3
						fi
						break 2
					;;
					n|N)
						echo "No problem"
						break 2
					;;
					"Quit")
						exit
					;;
					*)
						echo "No problem"
					;;
				esac
			;;
			"Leave")
				break
			;;
			"Quit")
				exit
			;;
			*)
				echo "See you later."
				echo
			;;
		esac
	done
	cont
}

#Survivor 2
# Global variables needed: missionTask suppliesCollected previousSuppliesCount
# suppliesCollected is just a subtraction done at the start of the day: suppliesCollected="$(($suppliesCount - $previousSuppliesCount))"
# previousSuppliesCount is as follows: previousSuppliesCount=$suppliesCount at the start of the part of the game when you go after suppliess.
function survivor2() {
	local randChance
	local option
	local task
	task=2
	echo
	echo "Whats going on with you $userName"
	select option in Talk Mission Complete Leave Quit; do
		case "$option" in
			"Talk")
				echo "Ive been a bit busy organizing stuff around camp"
				echo "I have a mission for you if you are ready for one"
				break 2
			;;
			"Mission")
				echo "Alright, heres the mission."
				echo "I need you to gather some of the bullets from the supplies storages."
				randChance=$((1 + RANDOM % 10))
				missionTask=$(($storageCount / $randChance))
				echo "You need to get $missionTask bullets to complete the mission."
				echo "Good luck $userName."
				task=1
				break 2
			;;
			"Complete")
				if [ "$task" == 1 ]; then
					echo "The mission is not compelte yet $userName you silly goose"
				else
					echo "Is the mission finished $userName?"
					if [ "$suppliesCollected" >= "$missionTask" ]; then
						echo "Awesome!"
						(( suppliesCount = $suppliesCount + 1 ))
						echo "You got one supplies."
					else
						echo "Nice try, see me again some other time for another task."
						(( missionTask = $missionTask + 126 ))
					fi
					task=2
				fi
				break 2
			;;
			"Leave")
				break
			;;
			"Quit")
				exit
			;;
			*)
			;;
		esac
	done
	cont
}


function survivor3() {
	local option
	local randChance1
	local randChance2
	echo
	echo "How are you doing $userName?"
	select option in Talk Assistance Leave Quit; do
		case "$option" in
			"Talk")
				echo "Kind of busy at the moment."
				break 2
			;;
			"Assistance")
				echo "I guess I can give you some advice."
				randChance1=$((1 + RANDOM % 2))
				if [ $randChance1 == 1 ]; then
					randChance2=$((1 + RANDOM % 20))
					if [ "$randChance2" -le 6 ]; then
						echo "Take these supplies I got."
						(( suppliesCount = $suppliesCount + 1 ))
					elif [ "$randChance2" -ge 7 ] || [ "$randChance2" -le 12 ]; then
						echo "Take these suppliess I have."
						(( suppliesCount = $suppliesCount + 2 ))
					elif [ "$randChance2" -le 13 ] || [ "$randChance2" -ge 15 ]; then
						echo "Take these suppliess I have."
						(( suppliesCount = $suppliesCount + 3 ))
					elif [ "$randChance2" -le 16 ] || [ "$randChance2" -ge 18 ]; then
						echo "Take these suppliess I have."
						(( suppliesCount = $suppliesCount + 4 ))
					elif [ $randChance2 == 19 ]; then
						echo "Take these suppliess I have."
						(( suppliesCount = $suppliesCount + 5 ))
					fi
					break 2
				else
					echo "Sorry I do not have any supplies to give you. Come back another time"
					break 2
				fi
			;;
			"Leave")
				break
			;;
			"Quit")
				exit
			;;
			*)
			;;
		esac
	done
	cont
}

function survivor4() {
	local option
	echo
	echo "So, have you found anything cool on your adventures?"
	select option in Talk Trade Leave Quit; do
		case "$option" in
			"Talk")
				echo "Let me know if you find anything cool i would love to add it to my collection!"
				break 2
			;;
			"Trade")
				echo "Lemme see what ya got."
				select goods in Supplies Meds Cancel Quit; do
					case "$goods" in
						"Supplies")
							echo "I already have to many supplies"
							echo "Sorry I can't take anymore. Thanks anyway."
							break 3
						;;
						"Meds")
							echo "You have Medication though! I really need those"
							read -p "I will give you 5 supplies for those meds. (y/n/barter) " deal
							case "$deal" in
								y|Y)
									echo "Pleasure doing business with you."
									(( medsCount = $medsCount - 1 ))
									(( suppliesCount = $suppliesCount + 5 ))
									break 3
								;;
								n|N)
									echo "Wasting my time huh"
									echo "come back when you wanna actually do business"
									break 3
								;;
								"barter"|"Barter")
									echo "Trying to barter with me? i aint budging"
									break 3
								;;
								"Quit")
									exit
								;;
								*)
									echo "So, we gotta deal or not?"
								;;
							esac
						;;
						"Cancel")
							echo "lol what?"
						;;
						"Quit")
							exit
						;;
						*)
						;;
					esac
				done
			;;
			"Leave")
				break
			;;
			"Quit")
				exit
			;;
			*)
			;;
		esac
	done
	cont
}

function survivor5() {
	local option
	local answer
	local clarification
	echo
	echo "What do you want $userName, the government might be listening"
	select option in Talk Quiz Leave Quit; do
		case "$option" in
			"Talk")
				echo "I am busy right now but I have some questions to ask"
				break 2
			;;
			"Quiz")
				echo "Ok, so here is a question"
				read -p "Do you think the government caused the apocalypse on purpose" answer
				case "$answer" in
					"no")
						read -p "WRONG ANS- the goverment created it as a means of population control?" clarification
						case "$clarification" in
							"yes")
								echo "Correct, I will never trust the government after this. Nor the miltary."
								echo "Thank you for sidin with me, here are some meds"
								(( medsCount = $medsCount + 1 ))
								break 2
							;;
							"Quit")
								exit
							;;
							*)
								echo "The voices in my head are telling me about the government stop wasting my time"
								echo "Anyway, the answer is NO"
								break 2
							;;
						esac
						break 2
					;;
					"Quit")
						exit
					;;
					*)
						echo "WRONG, the government is always trynna take away our meds and supplies"
						break 2
					;;
				esac	
			;;
			"Leave")
				break
			;;
			"Quit")
				exit
			;;
			*)
			;;
		esac
	done
	cont
}

function survivor6() {
	local option
	echo
	echo "Whaddya want bub?"
	select option in Talk Help Leave Quit; do
		case "$option" in
			"Talk")
				echo "Come to hear the tales of my war glory? Well I'd love to share with you kiddo."
				echo "It all started when I joined the military in......"
				read -p "You feel this story may go on for a while. Do you want to keep listening? (y|n) " choice
				case "$choice" in
					y|Y)
						cat survivor8text | less
						break 2
					;;
					n|N)
						echo "You kidding me? Why would you even ask and make me start talking if ya ain't listning?"
						break 2
					;;
				esac
			;; 
			"Help")
				echo "My combat experience impress you that much? You know what? Sure, I'm feeling generous today. I'll try to bring something back for you when I go out."
				read -p "Ask for help? (y|n) " assistance
				case "$assistance" in
					y|Y)
						scare=$((1 + RANDOM % 10))
						if [ "$scare" -gt 1 ]; then
							scareRandom
							echo "The day was pretty rough... I couldn't manage to find enough supplies for the both of us"
						else
							
							echo "My expert military grade expertise allowed me to get this for ya. OOH RAH!"
							echo
							echo "The supplies today are located in the following: "
							echo
							echo ${storageArray[*]}
						fi
						break 2
					;;
					n|N)
						echo "So, you think you good on your own? Good, I didn't want to have to deal with carrying the extra weight anyways."    
						break 2
					;;
				esac
			;;
			"Leave")
				break
			;;
			"Quit")
				exit
			;;
		esac
	done
	cont
}

function campCenter() {
	clear
	echo "In the center of the abandoned city in the ruins is the camp center."
	echo "Where some go to pray and help others in need by giving away supplies, although it is rare." 
	echo "In the center there is a fountain people gather around"
	echo "The water is looking good and you are thirsty do you take a drink?"
	echo "Or do you wait for someone to come by"
	echo "1. Drink"
	echo "2. wait"
	select option in drink "wait for supplies" leave Quit; do
		case "$option" in
			"drink")
				echo "You take a sip of the water from the fountain... It might have not been a good idead."
				break 2
			;;
			"wait and beg for supplies")
				read -p ": " command location
				scavenge
				case "$command" in
					"cat")
						if [ "$location" == "campCenter" ] || [ "$location" == "supplies" ]; then
							if [ 1 == $((1 + RANDOM % 5)) ]; then									
								(( suppliesCount = $suppliesCount + 1 ))
								echo "Someone gave you supplies!"
							else
								echo "You sat around begging for nothing"
							fi
							break 2
						fi
					;;
					q|Q)
						exit
					;;
					*)
						echo "You leave after a quick prayer"
						echo "Things are quite lonely nowadays..."
						clear
						echo -e "${BLINK}waiting...${NORMAL}"
						sleep 2
						scareRandom
						break 2
					;;
				esac
			;;
			"leave")
				echo "No supplies today. You leave disappointed."
				break
			;;
			"Quit")
				exit
			;;
			*)
			;;
		esac
	done
	cont
}

function makeCity() {
	local difficulty=1
	local storageDifficulty=12
	local permArray=("" r w x rw rx wr wx xr xw rwx rxw wrx wxr xrw xwr)
	prefix="$PWD/$1"
	saveFile="$prefix/.$1.txt"
	if [ -d "$prefix" ]; then
		read -p "Do you want to overwrite this existing save? (y/n) " overwrite
		case "$overwrite" in
			y|Y)
				chmod -R 777 $prefix
				rm -r $prefix
				mkdir $prefix
			;;
			n|N)
				read -p "Please enter a new save name that does not contain a number: " prefix
				if [ "$prefix" == "q" ] || [ "$prefix" == "Q" ]; then
					exit
				elif [ -d $prefix ]; then
					break
				fi
				mkdir $prefix
				saveFile="$prefix/.$prefix.txt"

			;;
			q|Q)
				exit
			;;
			*)
				echo "That is not a valid option"
			;;
		esac
	else
		mkdir $prefix
	fi

	touch $saveFile
	chmod +w $saveFile
	mkdir $prefix/city

	storageCount=0
	roomCount=0
	buildings=$(($difficulty + RANDOM % 5))
	for((t = 1; t <= buildings; t++)); do
		mkdir $prefix/city/building$t
		room1=$(($difficulty + RANDOM % 5))
		for((b1 = 1; b1 <= room1; b1++)); do
			mkdir $prefix/city/building$t/room$b1
			room2=$(($difficulty + RANDOM % 5))
			for((b2 = 1; b2 <= room2; b2++)); do
				mkdir $prefix/city/building$t/room$b1/room$b2
				storage=$((1 + RANDOM % $storageDifficulty))
				(( roomCount = $roomCount + 1 ))
				if [ ! -f storage ] && [ $storage == 1 ]; then
					(( storageCount = $storageCount + 1 ))
					storageArray[$storageCount]="$prefix/city/building$t/room$b1/room$b2/storage"
					echo "SUPPLIES!" > $prefix/city/building$t/room$b1/room$b2/storage
					storageIntArray[$storageCount]=$(( t * 1000 + b1 * 100 + b2 * 10 + 1 ))
				fi
			done
		done
	done

	if [ "$storageCount" == 0 ]; then
		location=false
		while [ "$location" == "false" ]; do
			buildings=$(($difficulty + RANDOM % 5))
			room1=$(($difficulty + RANDOM % 5))
			room2=$(($difficulty + RANDOM % 5))
			if [ -d "$prefix/city/building$buildings/room$room1/room$room2" ]; then
				(( storageCount = $storageCount + 1 ))
				storageArray[$storageCount]="$prefix/city/building$buildings/room$room1/room$room2/storage"
				echo "SUPPLIES!" > $prefix/city/building$buildings/room$room1/room$room2/storage
				storageIntArray[$storageCount]=$(( (( t * 1000 )) + (( b1 * 100 )) + (( b2 * 10 )) + 1 ))
				location=true
			fi
		done
	fi

	for i in "${storageIntArray[@]}"; do
		local BuildingIntDef="${i:0:1}"
		local RoomAIntDef="${i:1:1}"
		local RoomBIntDef="${i:2:1}"
		chmod "=${permArray[$((1 + RANDOM % 15))]}" $prefix/city/building$BuildingIntDef/room$RoomAIntDef/room$RoomBIntDef 2>/dev/null
		chmod "=${permArray[$((1 + RANDOM % 15))]}" $prefix/city/building$BuildingIntDef/room$RoomAIntDef 2>/dev/null
		chmod "=${permArray[$((1 + RANDOM % 15))]}" $prefix/city/building$BuildingIntDef 2>/dev/null
	done
}

#user start
select option in play readme Quit; do
	case $option in
		"play")
			storageCount=0
			suppliesCount=0
			dayCount=1
			chance=$((1 + RANDOM % 2))
			survivorLoc=0001
			medsCount=0
			survivor9SuppliesCount=0
			missionTask=0
			suppliesCollected=0
			previousSuppliesCount=$suppliesCount
			break
		;;
		"readme")
			cat readme | less
		;;
		"Quit")
			exit
		;;
		*)
		;;
	esac
done

hasFolder=false
command=""
clear
while [ "$hasFolder" == "false" ]; do
	read -p "Do you have a save folder already? (y/n) " folderName
	case "$folderName" in
		y|Y)
			read -p "What's your save folder called? (Must not contain a number)" folderName
			if [ -d  "$PWD/$folderName" ]; then
				echo "Alright, let's get started."
				hasFolder=true
				saveFile="$PWD/$folderName/.$folderName.txt"
				getSave
				prefix=$PWD/$folderName
				goToSurvivorLoc
				cont
			else
				echo "Oops. It looks like that directory doesn't exist yet."
				cont
			fi
		;;
		n|N)
			echo -e "Let's create a new save folder by ${GREEN}m${NC}a${GREEN}k${NC}e a new ${GREEN}dir${NC}ectory."
			echo "It can't contain a number."
			read -p "${GREEN}mkdir${NORMAL} " folderName
			if [ "$folderName" == "q" ] || [ "$folderName" == "Q" ]; then
				exit
			fi
			makeCity "$folderName"
			hasFolder=true
			read -p "What is your name? " userName
			save
			cat intro | less
			cont
		;;
		q|Q)
			exit
		;;
		*)
		;;
	esac
done

if [ "$dayCount" == 1 ]; then
	cd $prefix/city
fi

for ((dayCount ; dayCount < 8 ; dayCount++)); do
	dayComplete=0
	suppliesCollected=$(($suppliesCount - $previousSuppliesCount))
	if [ $dayCount == 1 ]; then
		clear
		read -p "You're experiencing some memory loss and can't seem to remember how to do some things. Travel thorugh your memories on how to surive in the wasteland? [TUTORIAL] (y/n) " tutorial
		case "$tutorial" in
			y|Y)
				clear
				echo "Every day allows you the option of choosing a survivor to speak with, where they will then ${GREEN}list${NC} their services."
				echo "You can also ${GREEN}skip${NC} interacting with people for the day and go straight to scavenging"
				echo "Look around you to see what you can explore by typing ${GREEN}ls${NC}."
				echo "Try looking around for ${CYAN}storage containers${NC} in different ${CYAN}buildings${NC} and ${CYAN}rooms${NC}."
				echo "You can move by changing your directory ${GREEN}cd${NC}."
				echo "If you're having trouble getting onto a certain room, try upgrading your suvivors permissions through ${GREEN}chmod${NC}."
				echo "${GREEN}read${NC}, ${GREEN}write${NC}, and e${GREEN}execute${NC} permissions are available."
				echo "There might be very well hidden rooms in a particular building. ${GREEN}-a${NC} should allow you to look harder."
				echo "If you don't feel like talking or exploring, you can beg instead by going to the ${GREEN}Camp Center${NC}. Or just drink water, "
				echo "whatever suits your fancy."
				echo
				cont
			;;
			n|N)
				echo "You recollect your thoughts to discover things you beleived you had forgotten."
			;;
			q|Q)
				exit
			;;
			*)
			;;
		esac
	fi
	clear
	
	echo "${BOLD}Day: $dayCount     | Supplies: $suppliesCount     | Meds: $medsCount${NORMAL}"
	select option in Kyle Survivor2 Survivor3 Survivor4 Survivor5 Survivor6 CampCenter Skip Quit; do
	echo "${BOLD}Day: $dayCount     | Supplies: $suppliesCount     | Meds: $medsCount${NORMAL}"
		case "$option" in
			"Kyle")
				kyle
			;;
			"Survivor2")
				survivor2
			;;
			"Survivor3")
				survivor3
			;;
			"Survivor4")
				survivor4
			;;
			"Survivor5")
				survivor5
			;;
			"Survivor6")
				survivor6
			;;
			"CampCenter")
				campCenter
			;;
			"Skip")
				break
			;;
			"Quit")
				dayComplete=1
				save
				exit
			;;
			*)
			;;
		esac
	done
	commandCase
	dayComplete=1
	cont
	save
done

clear
if [ "$suppliesCount" == 0 ]; then
	cd ~
	cat gameover
	printLose
else
	cd ~
	cat gamewin
	printWin
fi
echo "You finished the game with $suppliesCount supplies(s)."

exit
