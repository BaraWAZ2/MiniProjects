#!/usr/bin/env bash

######################################################################################
### Script Variables #################################################################
######################################################################################

### Technical ########################################################################

BACKUP_DIRECTORY_PATH="$HOME/bara_command_backup"
DISPLAY_DURATION=10
REFRESH_RATE=1

### ANSI Formatting ##################################################################

RED="91"
MAGENTA="95"
CYAN="96"
WHITE="97"
DEFAULT="39"

BOLD="1"
UNDERLINE="4"
STRIKETHROUGH="9"

RESET="0"

######################################################################################
### Functions ########################################################################
######################################################################################

### Utilities ########################################################################

line_break() {
	echo "$(ansi_format STRIKETHROUGH)                                                  $(ansi_format RESET)"
}

wait_for_enter() {
	read -p "Press [ENTER] to go Back..."
}

yes_no() {
	local RESPONSE="$1"
	while [[ ! "$RESPONSE" =~ ^[YyNn]$ ]]; do
		read -p "please only enter [y/n]: " RESPONSE
	done
	RESPONSE="${RESPONSE,,}"
	echo "$RESPONSE"
}

verify_privileges() {
	local RESPONSE
	read -p "This action requires root privileges, proceed? [y/n]: " RESPONSE
	[[ "$(yes_no "$RESPONSE")" == 'y' ]]
}

check_backup_directory() {
	mkdir -p "$BACKUP_DIRECTORY_PATH" > /dev/null 2>&1
}

read_FILE_NAME() {
	local MESSAGE="$1" DIRECTORY="$2" FILE_NAME

	if ! cd "$DIRECTORY" > /dev/null; then
		return 1
	fi

	echo -n "$MESSAGE" >&2
	read -e -p "" FILE_NAME
	while [[ ! -e "$FILE_NAME" ]]; do
		echo -n "Error: file not found, retry: " >&2
		read -e -p "" FILE_NAME
	done
	cd - > /dev/null
	echo "$FILE_NAME"
}

is_number() {
	[[ -n "$1" && "$1" =~ ^-?[0-9]+$ ]]
}

valid_ip() {
	[[ "$1" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+(/[0-9]+)?$ ]]
}

ansi_format() {
	local NEW_FORMATTING=""
	for rule in "$@"; do
		NEW_FORMATTING+="\033[${!rule}m"
	done
	echo -ne "$NEW_FORMATTING"
}

clickable() {
	echo -e "\e]8;;$1\a$1\e]8;;\a"
}

### Option 1 #########################################################################

option1() {

	ansi_format BOLD
	echo "System Information..."
	ansi_format RESET
	line_break

	echo "$(ansi_format CYAN)Username               $(ansi_format WHITE):$(ansi_format MAGENTA) $(whoami)$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)Hostname               $(ansi_format WHITE):$(ansi_format MAGENTA) $(uname --nodename)$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)OS                     $(ansi_format WHITE):$(ansi_format MAGENTA) $(uname --operating-system)$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)Kernel Version         $(ansi_format WHITE):$(ansi_format MAGENTA) $(uname --kernel-version)$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)Uptime                 $(ansi_format WHITE):$(ansi_format MAGENTA)$(uptime)$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)Date/Time              $(ansi_format WHITE):$(ansi_format MAGENTA) $(date +'%___Y/%_m/%_d %__a [%_I:%0M:%0S %_p]')$(ansi_format WHITE)"
	line_break

	wait_for_enter
	return 0
}

### Option 2 #########################################################################

option2() {

	ansi_format BOLD
	echo "Resource Usage Monitor..."
	ansi_format RESET
	line_break

	echo -e "\nCPU Usage :\n"
	vmstat $REFRESH_RATE $DISPLAY_DURATION
	# ^^^ Memory and CPU usage with Process Ids
	local STATUS1=$?
	echo
	line_break

	echo -e "\nMemory Usage :\n"
	ps aux --sort -%cpu | head -n 6
	# ^^^ Process status [All users][detailed info User/cpu/memory][Include Daemon Processes]
	local STATUS2=$?
	echo
	line_break

	echo "processes ended with status codes $STATUS1 and $STATUS2"
	line_break

	wait_for_enter
	return 0
}

### Option 3 #########################################################################

option3_1() {

	echo "Creating Backup..."
	line_break

	local FILE_PATH
	read -e -p "Enter file/directory path: " FILE_PATH
	if [[ ! -e "$FILE_PATH" ]]; then
		echo "Error: path provided does not lead to a valid file/directory"
		line_break

		wait_for_enter
		return 1
	fi

	rsync -avhz --progress "$FILE_PATH" "$BACKUP_DIRECTORY_PATH"
	# Synchronize [Comprehensive Copy][Verbose][Human readable][Compressed][show Progress]
	local STATUS=$?
	echo "archiving ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option3_2() {

	echo "Listing Existing Backups..."
	line_break

	ls -lh "$BACKUP_DIRECTORY_PATH" --no-group --color=always | sed -re 's/^[^ ]* //'
	# ^^^ List files [Long listing][Human readable][without group column][forcing Colors]
	#  manipulates Stream [Removes first column] (permissions) ^^^
	local STATUS=$?
	echo "listing backups ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option3_3() {

	echo "Restoring from Backup..."
	line_break

	local FILE_NAME=$(read_FILE_NAME "Enter file name: " "$BACKUP_DIRECTORY_PATH")
	rsync -avz --progress "$BACKUP_DIRECTORY_PATH/$FILE_NAME"
	# Synchronize [Comprehensive Copy][Verbose][Human readable][Compressed][show Progress]
	local STATUS=$?
	echo "restoring ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option3_4() {

	echo "Deleting from Backup..."
	line_break

	local FILE_NAME=$(read_FILE_NAME "Enter file name: " "$BACKUP_DIRECTORY_PATH")
	rm "$BACKUP_DIRECTORY_PATH/$FILE_NAME" -ri
	local STATUS=$?
	echo "deleting ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option3() {

	while true; do

		ansi_format BOLD
		echo "Backup Management..."
		ansi_format RESET
		line_break

		if ! check_backup_directory; then
			echo "Error: backup directory is not found and could not be created..."
			line_break

			wait_for_enter
			return 1
		fi

		echo "[1] 📤 $(ansi_format RED)C$(ansi_format WHITE)reate backup"
		echo "[2] 📋 $(ansi_format RED)L$(ansi_format WHITE)ist existing backups"
		echo "[3] 📥 $(ansi_format RED)R$(ansi_format WHITE)estore from backup"
		echo "[4] 🗑️  $(ansi_format RED)D$(ansi_format WHITE)elete old backup"
		echo "[5] ↩️  $(ansi_format RED)B$(ansi_format WHITE)ack"
		line_break

		read -p "choice: " CHOICE
		clear

		case $CHOICE in

			1 | c | C)
				option3_1
			;;

			2 | l | L)
				option3_2
				;;

			3 | r | R)
				option3_3
				;;

			4 | d | D)
				option3_4
				;;

			5 | b | B)
				break
				;;

			*)
				echo "Error: choice '$CHOICE' is not defined"
				line_break

				wait_for_enter
				;;
		esac
		clear
	done
	clear
	return 0
}

### Option 4 #########################################################################

option4_1() {

	echo "Adding User..."
	line_break

	local USERNAME
	read -p "Type the name of the user you want to add: " USERNAME
	if getent passwd "$USERNAME" > /dev/null; then
		echo "There already exists a user with the name '$USERNAME'..."
		line_break

		wait_for_enter
		return 1
	fi

	sudo adduser "$USERNAME"
	local STATUS=$?
	echo "adding user ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option4_2() {

	echo "Deleting User..."
	line_break

	local USERNAME
	read -e -p "Type the name of the user you want to delete: " USERNAME
	if ! getent passwd "$USERNAME" > /dev/null; then
		echo "There does NOT exists a user with the name '$USERNAME'..."
		line_break

		wait_for_enter
		return 1
	fi

	local DELETE_HOME
	read -p "Do you want to delete home directory as well? [y/n]: " DELETE_HOME
	DELETE_HOME="$(yes_no "$DELETE_HOME")"

	if [[ "$DELETE_HOME" == "y" ]]; then
		sudo deluser "$USERNAME" --remove-home
	else
		sudo deluser "$USERNAME"
	fi
	local STATUS1=$?
	sudo pkill -u "$USERNAME"
	local STATUS2=$?
	echo "deleting user processes ended with status codes $STATUS1 and $STATUS2"
	line_break

	wait_for_enter
	return $STATUS1
}

option4_3() {

	echo "Showing User Groups..."
	line_break

	local USERNAME
	read -e -p "Type the name of the user you want to view their groups: " USERNAME
	if ! getent passwd "$USERNAME" > /dev/null; then
		echo "There does NOT exists a user with the name '$USERNAME'..."
		line_break

		wait_for_enter
		return 1
	fi

	echo "Groups that user '$USERNAME' is a member of are:"
	id -nG "$USERNAME"
	local STATUS=$?
	# ^^^ Identification [Names, not ids][include all Groups]
	echo "showing user groups ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option4_4() {

	echo "Changing User Password..."
	line_break

	local USERNAME
	read -e -p "Type the name of the user you want to change their password: " USERNAME
	if ! getent passwd "$USERNAME" > /dev/null; then
		echo "There does NOT exists a user with the name '$USERNAME'..."
		line_break

		wait_for_enter
		return 1
	fi

	sudo passwd "$USERNAME"
	local STATUS=$?
	echo "changing password ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option4_5() {

	echo "Switching User Lock status..."
	line_break

	local USERNAME
	read -e -p "Type the name of the user you want to switch their lock status: " USERNAME
	if ! getent passwd "$USERNAME" > /dev/null; then
		echo "There does NOT exists a user with the name '$USERNAME'..."
		line_break

		wait_for_enter
		return 1
	fi

	local LOCK_STATUS=$(sudo passwd -S "$USERNAME" 2> /dev/null | awk '{print $2}')
	#                   ^^^ Password [status]                      ^^^ Parsing/Formatting
	local STATUS=$?
	if (( STATUS != 0 )); then
		echo "Error: could not check the lock status of $USERNAME..."
		line_break

		wait_for_enter
		return 1
	fi

	local RESPONSE
	if [[ "$LOCK_STATUS" == "L" || "$LOCK_STATUS" == "LK" ]]; then
		echo "Lock status of user '$USERNAME' is [LOCKED]"
		read -p "Do you want to unlock user '$USERNAME'? [y/n]: " RESPONSE
		RESPONSE=$(yes_no "$RESPONSE")

		if [[ "$RESPONSE" == "y" ]]; then
			sudo passwd -u "$USERNAME"
			STATUS=$?
			echo "unlocking user ended with status code $STATUS"
		fi
	else
		echo "Lock status of user '$USERNAME' is [UNLOCKED]"
		read -p "Do you want to lock user '$USERNAME'? [y/n]: " RESPONSE
		RESPONSE=$(yes_no "$RESPONSE")

		if [[ "$RESPONSE" == "y" ]]; then
			sudo passwd -l "$USERNAME"
			STATUS=$?
			echo "locking user ended with status code $STATUS"
		fi
	fi
	line_break

	wait_for_enter
	return $STATUS
}

option4() {

	ansi_format BOLD
	echo "User Management..."
	ansi_format RESET
	line_break

	if ! verify_privileges; then
		line_break

		wait_for_enter
		return 1;
	fi
	clear

	while true; do
		ansi_format BOLD
		echo "User Management..."
		ansi_format RESET
		line_break

		echo "[1] 👤 $(ansi_format RED)A$(ansi_format WHITE)dd a user"
		echo "[2] 🪦 $(ansi_format RED)D$(ansi_format WHITE)elete a user"
		echo "[3] 💼 Show $(ansi_format RED)g$(ansi_format WHITE)roups of a user"
		echo "[4] 🗝️  Change $(ansi_format RED)p$(ansi_format WHITE)assword of a user"
		echo "[5] 🔒 $(ansi_format RED)L$(ansi_format WHITE)ock/Unlock the account of a user"
		echo "[6] ↩️  $(ansi_format RED)B$(ansi_format WHITE)ack"
		line_break

		read -p "choice: " CHOICE
		clear

		case $CHOICE in

			1 | c | C)
				option4_1
			;;

			2 | d | D)
				option4_2
				;;

			3 | g | G)
				option4_3
				;;

			4 | p | P)
				option4_4
				;;

			5 | l | L)
				option4_5
				;;

			6 | b | B)
				break
				;;

			*)
				echo "Error: choice '$CHOICE' is not defined"
				line_break

				wait_for_enter
				;;
		esac
		clear
	done
}

### Option 5 #########################################################################

option5_1() {

	echo "Searching in Logs..."
	line_break

	local search_keyword
	read -e -p "Type the keyword you want to search for: " search_keyword
	journalctl -g "$search_keyword"
	local STATUS=$?
	echo "searching log ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option5_2() {

	echo "Showing Recent Syslog..."
	line_break

	journalctl -n 50
	local STATUS=$?
	echo "showing recent syslog ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option5_3() {

	echo "Showing Failed Logins..."
	line_break

	faillog -a | less
	local STATUS=$?
	echo "showing failed logins ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option5_4() {

	echo "Showing Service Errors..."
	line_break

	journalctl -p err -x | less -R
	# ^^^ [Priority for ERRORS][with EXPLANATION]
	local STATUS=$?
	echo "showing service errors ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option5() {

	while true; do

		ansi_format BOLD
		echo "Log Management..."
		ansi_format RESET
		line_break

		echo "[1] 🔎 Search logs for a $(ansi_format RED)k$(ansi_format WHITE)eyword"
		echo "[2] 📜 Show last 50 lines of $(ansi_format RED)s$(ansi_format WHITE)yslog"
		echo "[3] ➜] Show failed $(ansi_format RED)l$(ansi_format WHITE)ogins"
		echo "[4] ⚠️  Show service $(ansi_format RED)e$(ansi_format WHITE)rrors"
		echo "[5] ↩️  $(ansi_format RED)B$(ansi_format WHITE)ack"
		line_break

		read -p "choice: " CHOICE
		clear

		case $CHOICE in

			1 | k | K)
				option5_1
			;;

			2 | s | S)
				option5_2
				;;

			3 | l | L)
				option5_3
				;;

			4 | e | E)
				option5_4
				;;

			5 | b | B)
				break
				;;

			*)
				echo "Error: choice '$CHOICE' is not defined"
				line_break

				wait_for_enter
				;;
		esac
		clear
	done
}

### Option 6 #########################################################################

option6_1() {

	echo "Pinging a host..."
	line_break

	local domain_name ping_times
	read -p "Enter the ip or domain name: " domain_name
	read -p "Enter how many times you want to ping: " ping_times
	while ! is_number "$ping_times"; do
		echo "You must enter an integer value"
		read -p "Enter how many times you want to ping: " ping_times
	done
	ping -c "$ping_times" "$domain_name"
	local STATUS=$?
	echo "pinging host ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option6_2() {

	echo "Resolving hostname to IP..."
	line_break

	local domain_name
	read -p "Enter the domain name: " domain_name
	local output=$(dig +short "$domain_name")
	local STATUS=$?
	if [[ -z "$output" ]]; then
		echo "Error: failed to fetch IP address for $domain_name"
	else
		echo "$output"
	fi
	echo "resolving hostname to IP ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option6_3() {

	echo "Displaying current IP and routes..."
	line_break

	echo "Current IP Information"
	ip addr show
	local STATUS=$?
	echo "displaying IP ended with status code $STATUS"
	line_break

	echo "Current Routing Information"
	ip route show
	local STATUS=$?
	echo "displaying routing table ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option6_4() {

	echo "Testing port availability..."
	line_break

	local port_number
	read -p "Enter port number: " port_number
	while ! is_number "$port_number" || (( port_number < 1 || port_number > 65535 )); do
		echo "You must enter an integer value between 1 and 65535"
		read -p "Enter port number: " port_number
	done

	nc -zv localhost "$port_number"
	# ^^^ NetCat [scan port for listenting daemons, sending Zero data][Verbose]
	local STATUS=$?
	echo "testing port availability ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option6_5() {

	echo "Toggling network interface..."
	line_break

	ip link show
	local STATUS=$?
	if (( STATUS != 0 )); then
		echo "Error: cannot access network interfaces..."
		line_break

		wait_for_enter
		return $STATUS
	fi

	local interface_name
	read -p "Enter interface name: " interface_name
	while ! ip link show "$interface_name" &> /dev/null; do
		echo "There is no interface available with the name $interface_name"
		read -p "Enter interface name: " interface_name
	done

	local RESPONSE
	if ip link show "$interface_name" | grep -q "<*.*UP*.*>"; then

		read -p "This interface is UP (ENABLED), do you want it DOWN (DISABLED) ? (y/n): " RESPONSE
		RESPONSE=$(yes_no "$RESPONSE")

		if [[ "$RESPONSE" == "y" ]]; then
			sudo ip link set "$interface_name" down
			STATUS=$?
			echo "disabling interface ended with status code $STATUS"
		fi
	else

		read -p "This interface is DOWN (DISABLED), do you want it UP (ENABLED) ? (y/n): " RESPONSE
		RESPONSE=$(yes_no "$RESPONSE")

		if [[ "$RESPONSE" == "y" ]]; then
			sudo ip link set "$interface_name" up
			STATUS=$?
			echo "enabling interface ended with status code $STATUS"
		fi
	fi
	line_break

	wait_for_enter
	return $STATUS
}

option6() {

	while true; do

		ansi_format BOLD
		echo "Network Tools..."
		ansi_format RESET
		line_break

		echo "[1] 🔊 $(ansi_format RED)P$(ansi_format WHITE)ing a host"
		echo "[2] 🔄 $(ansi_format RED)R$(ansi_format WHITE)esolve hostname to ip"
		echo "[3] 🪪 $(ansi_format RED)D$(ansi_format WHITE)isplay current IP and routes"
		echo "[4] 📣 $(ansi_format RED)T$(ansi_format WHITE)est port availability"
		echo "[5] ⚙️  Enable/Disable a $(ansi_format RED)n$(ansi_format WHITE)etwork interface"
		echo "[6] ↩️  $(ansi_format RED)B$(ansi_format WHITE)ack"
		line_break

		read -p "choice: " CHOICE
		clear

		case $CHOICE in

			1 | p | P)
				option6_1
			;;

			2 | r | R)
				option6_2
				;;

			3 | d | D)
				option6_3
				;;

			4 | t | T)
				option6_4
				;;

			5 | n | N)
				option6_5
				;;

			6 | b | B)
				break
				;;

			*)
				echo "Error: choice '$CHOICE' is not defined"
				line_break

				wait_for_enter
				;;
		esac
		clear
	done
}

### Option 7 #########################################################################

option7() {

	while true; do

		ansi_format BOLD
		echo "Task Scheduling..."
		ansi_format BOLD
		line_break

		echo "[1] 📝 $(ansi_format RED)E$(ansi_format WHITE)dit tasks"
		echo "[2] 📋 $(ansi_format RED)L$(ansi_format WHITE)ist tasks"
		echo "[3] ↩️  $(ansi_format RED)B$(ansi_format WHITE)ack"
		line_break

		read -p "choice: " CHOICE
		clear

		case $CHOICE in

			1 | e | E)
				crontab -e
				line_break
				wait_for_enter
			;;

			2 | l | L)
				crontab -l
				line_break
				wait_for_enter
				;;

			3 | b | B)
				break
				;;

			*)
				echo "Error: choice '$CHOICE' is not defined"
				line_break

				wait_for_enter
				;;
		esac
		clear
	done
}

### Option 8 #########################################################################

option8_1() {

	echo "Changing static hostname..."
	line_break

	echo "Current host information:"
	hostnamectl
	local STATUS=$?
	if (( STATUS != 0 )); then
		echo "Error: cannot display host information..."
		line_break

		wait_for_enter
		return $STATUS
	fi
	line_break

	local new_hostname
	read -p "Enter new hostname: " new_hostname
	sudo hostnamectl set-hostname "$new_hostname"
	STATUS=$?
	echo "changing static hostname ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option8_2() {

	echo "Updating static MOTD..."
	line_break

	if ! verify_privileges; then
		line_break

		wait_for_enter
		return 1
	fi

	sudo nano /etc/motd
	local STATUS=$?
	echo "updating static MOTD ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option8_3() {

	echo "Setting timezone..."
	line_break

	echo "Current timezone information:"
	timedatectl status
	local STATUS=$?
	if (( STATUS != 0 )); then
		echo "Error: cannot view timezone information..."
		line_break

		wait_for_enter
		return $STATUS
	fi
	line_break

	local NEW_TIMEZONE
	while true; do
		read -p "Press [ENTER] to start viewing timezone list..."
		timedatectl list-timezones | less
		STATUS=$?
		if (( STATUS != 0 )); then
			echo "Error: cannot view timezone list..."
			line_break

			wait_for_enter
			return $STATUS
		fi
		line_break

		read -p "Enter the full name of the timezone you want to switch to: " NEW_TIMEZONE
		local COUNT_MATCHES=$(timedatectl list-timezones | grep -i "$NEW_TIMEZONE" | wc -l)
		#                                               WordCount [number of Lines]  ^^^
		if (( COUNT_MATCHES == 1 )); then
			break
		fi
		echo "Error: Invalid timezone"
	done

	NEW_TIMEZONE=$( timedatectl list-timezones | grep -i "$NEW_TIMEZONE" )
	echo "new timezone: $NEW_TIMEZONE"
	timedatectl set-timezone "$NEW_TIMEZONE"
	STATUS=$?
	echo "changing timezone ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option8_4() {

	echo "Configuring IP..."
	line_break

	if ! verify_privileges; then
		line_break

		wait_for_enter
		return 1;
	fi

	echo "Current IP information:"
	ip address show
	local STATUS=$?
	if (( STATUS != 0 )); then
		echo "Error: could not view IP address information..."
		line_break

		wait_for_enter
		return $STATUS
	fi
	line_break

	local interface
	read -p "Select the interface you want to configure: " interface
	while ! ip link show "$interface" &> /dev/null; do
		read -p "Interface $interface does not exist, retry: " interface
	done

	local RESPONSE
	read -p "Do you want to ADD an ip to this device or REMOVE an ip from it? [a/r]: " RESPONSE
	while [[ ! "$RESPONSE" =~ ^[AaRr]$ ]]; do
		read -p "Please only enter [a/r]: " RESPONSE
	done
	RESPONSE="${RESPONSE,,}"

	local IP_ADDRESS
	if [[ "$RESPONSE" == "a" ]]; then

		read -p "Enter the ip you want to add: " IP_ADDRESS
		while ! valid_ip "$IP_ADDRESS"; do
			read -p "Invalid IP format, retry: " IP_ADDRESS
		done
		sudo ip address add "$IP_ADDRESS" dev "$interface"
		STATUS=$?
		echo "add ip address to interface ended with status code $STATUS"
	else

		read -p "Enter the ip you want to remove: " IP_ADDRESS
		while ! valid_ip "$IP_ADDRESS"; do
			read -p "Invalid IP format, retry: " IP_ADDRESS
		done
		sudo ip address del "$IP_ADDRESS" dev "$interface"
		STATUS=$?
		echo "deleting ip address from interface ended with status code $STATUS"
	fi
	line_break

	wait_for_enter
	return $STATUS
}

option8() {

	while true; do

		ansi_format BOLD
		echo "Edit System Information..."
		ansi_format RESET
		line_break

		echo "[1] 💻 Change static $(ansi_format RED)h$(ansi_format WHITE)ostname"
		echo "[2] 👋 Update static $(ansi_format RED)M$(ansi_format WHITE)OTD"
		echo "[3] 🕒 Set $(ansi_format RED)t$(ansi_format WHITE)imezone"
		echo "[4] 🛜 Configure $(ansi_format RED)I$(ansi_format WHITE)P addresses"
		echo "[5] ↩️  $(ansi_format RED)B$(ansi_format WHITE)ack"
		line_break

		read -p "choice: " CHOICE
		clear

		case $CHOICE in

			1 | h | H)
				option8_1
			;;

			2 | m | M)
				option8_2
				;;

			3 | t | T)
				option8_3
				;;

			4 | i | I)
				option8_4
				;;

			5 | b | B)
				break
				;;

			*)
				echo "Error: choice '$CHOICE' is not defined"
				line_break

				wait_for_enter
				;;
		esac
		clear
	done
}

### Option 9 #########################################################################

option9_1() {

	echo "Updating Package List..."
	line_break

	sudo apt update
	local STATUS=$?
	echo "updating package list ended with status code $STATUS"
	line_break

	local RESPONSE
	read -p "Do you want to view the upgradable utilities? [y/n]: " RESPONSE
	RESPONSE=$(yes_no "$RESPONSE")
	if [[ "$RESPONSE" == "y" ]]; then
		apt list --upgradable | less
		STATUS=$?
	fi
	line_break

	wait_for_enter
	return $STATUS
}

option9_2() {

	echo "Upgrading Package List..."
	line_break

	sudo apt upgrade
	local STATUS=$?
	echo "updating package list ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option9_3() {

	echo "Installing a Package..."
	line_break

	local package_name
	read -p "Insert the name of the package you want to install: " package_name
	sudo apt install "$package_name"
	local STATUS=$?
	echo "installing package list ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option9_4() {

	echo "Removing a Package..."
	line_break

	local package_name
	read -p "Insert the name of the package you want to remove: " package_name
	sudo apt remove "$package_name"
	local STATUS=$?
	echo "removing package list ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option9_5() {

	echo "Searching for a Package..."
	line_break

	local package_name
	read -p "Insert the name of the package you want to search for: " package_name
	apt search "$package_name" | less
	local STATUS=$?
	echo "searching for package ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option9_6() {

	echo "Viewing Package Details..."
	line_break

	local package_name
	read -p "Insert the name of the package you want to view the details of: " package_name
	apt show "$package_name" | less
	local STATUS=$?
	echo "viewing package details list ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option9() {

	ansi_format BOLD
	echo "Package Management..."
	ansi_format RESET
	line_break

	if ! verify_privileges; then
		line_break

		wait_for_enter
		return 1;
	fi
	clear

	while true; do

		ansi_format BOLD
		echo "Package Management..."
		ansi_format RESET
		line_break

		echo "[1] 🛒 Up$(ansi_format RED)d$(ansi_format WHITE)ate package list"
		echo "[2] 🚀 Up$(ansi_format RED)g$(ansi_format WHITE)rade package list"
		echo "[3] 📥 $(ansi_format RED)I$(ansi_format WHITE)nstall a package"
		echo "[4] 🗑️  $(ansi_format RED)R$(ansi_format WHITE)emove a package"
		echo "[5] 🔎︎ $(ansi_format RED)S$(ansi_format WHITE)earch for a package"
		echo "[6] 🪪 $(ansi_format RED)V$(ansi_format WHITE)iew package details"
		echo "[7] ↩️  $(ansi_format RED)B$(ansi_format WHITE)ack"
		line_break

		read -p "choice: " CHOICE
		clear

		case $CHOICE in

			1 | d | D)
				option9_1
			;;

			2 | g | G)
				option9_2
				;;

			3 | i | I)
				option9_3
				;;

			4 | r | R)
				option9_4
				;;

			5 | s | S)
				option9_5
				;;

			6 | v | V)
				option9_6
				;;

			7 | b | B)
				break
				;;

			*)
				echo "Error: choice '$CHOICE' is not defined"
				line_break

				wait_for_enter
				;;
		esac
		clear
	done
}

### Option 10 ########################################################################

option10_1() {

	echo "Enabling UFW..."
	line_break

	sudo ufw enable
	local STATUS=$?
	echo "enabling UFW ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option10_2() {

	echo "Disabling UFW..."
	line_break

	sudo ufw disable
	local STATUS=$?
	echo "disabling UFW ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option10_3() {

	echo "Allowing Port on UFW..."
	line_break

	local port_number
	read -p "Enter port number (use portnumber/protocol for protocol): " port_number
	sudo ufw allow "$port_number"
	local STATUS=$?
	echo "allowing port ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option10_4() {

	echo "Denying Port on UFW..."
	line_break

	local port_number
	read -p "Enter port number (use portnumber/protocol for protocol): " port_number
	sudo ufw deny "$port_number"
	local STATUS=$?
	echo "denying port ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option10_5() {

	echo "Listing Currently Applied UFW Rules..."
	line_break

	sudo ufw status numbered | less
	local STATUS=$?
	echo "listing rules ended with status code $STATUS"
	line_break

	wait_for_enter
	return $STATUS
}

option10() {

	ansi_format BOLD
	echo "Firewall Control..."
	ansi_format RESET
	line_break

	if ! verify_privileges; then
		line_break

		wait_for_enter
		return 1;
	fi
	clear

	while true; do

		ansi_format BOLD
		echo "Firewall Control..."
		ansi_format RESET
		line_break

		echo "[1] ✔️  $(ansi_format RED)E$(ansi_format WHITE)nable UFW"
		echo "[2] ❌ Di$(ansi_format RED)s$(ansi_format WHITE)able UFW"
		echo "[3] 🆗 $(ansi_format RED)A$(ansi_format WHITE)llow port"
		echo "[4] ⛔ $(ansi_format RED)D$(ansi_format WHITE)eny port"
		echo "[5] 📋 List $(ansi_format RED)r$(ansi_format WHITE)ules"
		echo "[6] ↩️  $(ansi_format RED)B$(ansi_format WHITE)ack"
		line_break

		read -p "choice: " CHOICE
		clear

		case $CHOICE in

			1 | e | E)
				option10_1
			;;

			2 | s | S)
				option10_2
				;;

			3 | a | A)
				option10_3
				;;

			4 | d | D)
				option10_4
				;;

			5 | r | R)
				option10_5
				;;

			6 | b | B)
				break
				;;

			*)
				echo "Error: choice '$CHOICE' is not defined"
				line_break

				wait_for_enter
				;;
		esac
		clear
	done
}

### Author ###########################################################################

author() {

	ansi_format BOLD
	echo "Author..."
	ansi_format RESET
	line_break

	echo "$(ansi_format CYAN)Name                   $(ansi_format WHITE):$(ansi_format MAGENTA) Bara Ayman Wazwaz$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)LinkedIn               $(ansi_format WHITE):$(ansi_format MAGENTA) $(clickable https://linkedin.com/in/bara-wazwaz)$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)Codeforces             $(ansi_format WHITE):$(ansi_format MAGENTA) $(clickable https://codeforces.com/profile/NitronBeam)$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)Leetcode               $(ansi_format WHITE):$(ansi_format MAGENTA) $(clickable https://leetcode.com/u/PEVPEIeuVA/)$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)Github                 $(ansi_format WHITE):$(ansi_format MAGENTA) $(clickable https://github.com/BaraWAZ2)$(ansi_format WHITE)"
	echo "$(ansi_format CYAN)DataCamp               $(ansi_format WHITE):$(ansi_format MAGENTA) $(clickable https://www.datacamp.com/portfolio/barawazwaz)$(ansi_format WHITE)"
	line_break

	wait_for_enter
	return 0
}

### Easter Egg #######################################################################

easter_egg() {

	echo "Yup, that's my gaming-related nickname :)"
	line_break

	wait_for_enter
}

### Main #############################################################################

main() {

	ansi_format WHITE BOLD

	while true; do

		ansi_format BOLD
		echo "Linux System Maintenance & Monitoring Toolkit..."
		ansi_format BOLD
		line_break

		echo "[ 1] 🪪 Show $(ansi_format RED)s$(ansi_format WHITE)ystem information"
		echo "[ 2] 📊 Monitor $(ansi_format RED)r$(ansi_format WHITE)esource usage"
		echo "[ 3] 📥 $(ansi_format RED)B$(ansi_format WHITE)ackup management"
		echo "[ 4] 👤 $(ansi_format RED)U$(ansi_format WHITE)ser management"
		echo "[ 5] 📜 $(ansi_format RED)L$(ansi_format WHITE)og management"
		echo "[ 6] 🖧  $(ansi_format RED)N$(ansi_format WHITE)etwork tools"
		echo "[ 7] 📑 $(ansi_format RED)T$(ansi_format WHITE)ask scheduling"
		echo "[ 8] 🔧 $(ansi_format RED)E$(ansi_format WHITE)dit system information"
		echo "[ 9] 📦 $(ansi_format RED)P$(ansi_format WHITE)ackage management"
		echo "[10] 🧱 $(ansi_format RED)F$(ansi_format WHITE)irewall control (UFW)"
		echo "[11] 🚪 E$(ansi_format RED)x$(ansi_format WHITE)it"
		echo "[12] ⭐ $(ansi_format RED)A$(ansi_format WHITE)uthor"
		line_break

		ansi_format RESET
		read -p "choice: " CHOICE
		clear

		case $CHOICE in

			1  | s | S)
				option1
			;;

			2  | r | R)
				option2
				;;

			3  | b | B)
				option3
				;;

			4  | u | U)
				option4
				;;

			5  | l | L)
				option5
				;;

			6  | n | N)
				option6
				;;

			7  | t | T)
				option7
				;;

			8  | e | E)
				option8
				;;

			9  | p | P)
				option9
				;;

			10 | f | F)
				option10
				;;

			11 | x | X)
				break
				;;

			12 | a | A)
				author
				;;

			NitronBeam)
				easter_egg
				;;

			*)
				echo "Error: choice '$CHOICE' is not defined"
				line_break

				wait_for_enter
				;;
		esac
		clear
	done

	ansi_format RESET

}

clear

######################################################################################
### Main Function Call ###############################################################
######################################################################################

main

######################################################################################
#  #
######################################################################################

