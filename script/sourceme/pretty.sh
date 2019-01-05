# Usage:
# printfverbose "$ ${cGREEN}make ${cPURPLE}$1${cNC}\n"

# let's assume nobody will use these variables...
cWHITE='\033[1;37m'
cGREEN='\033[0;32m'
cRED='\033[0;31m'
cPURPLE='\033[0;35m'
cNC='\033[0m'

function conditionalprintf() {
	if [ "$1" == "1" ]; then
		printf "$2"
		return 0
	fi
	return 1
}

function printffail() {
	test $? -eq 0
	_PREVIOUS_FAILED="$?"
	conditionalprintf "$_PREVIOUS_FAILED" "$1"
	if [ $? -eq 0 ]; then
		exit 1
	fi
}

function printfverbose() {
	conditionalprintf "$_VERBOSE" "$1"
	return 0
}
