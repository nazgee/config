#!/bin/bash

declare -A MAP=( \

[tools/8.4.09/Tools/bin/clang-10]=hexagon10-clang \
[tools/8.4.09/Tools/bin/hexagon-clang++]=hexagon-clang++ \
[tools/8.4.09/Tools/bin/hexagon-clang]=hexagon-clang \
[arm/10.0.3/bin/clang]=armllvm10-clang \
[arm/12.0.3/bin/clang]=armllvm12-clang \
[arm/4.0.12/bin/clang]=armllvm4-clang \
[arm/4.0.12/bin/../bin/clang]=armllvm4-clang \
[arm/4.0.12/bin/../bin/clang++]=arm4llvm4-clang++ \
[qnx710/host/linux/x86_64/usr/bin/qcc]=x86_64-qnx710-gcc \
[qnx710/host/linux/x86_64/usr/bin/q++]=x86_64-qnx710-g++ \
[gcc/aarch64-unknown-nto-qnx7.1.0/8.3.0/cc1]=aarch64-unknown-nto-qnx7-gcc \
[gcc/aarch64-unknown-nto-qnx7.1.0/8.3.0/cc1plus]=aarch64-unknown-nto-qnx7-g++ \
[gcc/x86_64-pc-nto-qnx7.1.0/8.3.0/cc1]=x86_64-pc-nto-qnx7-gcc \
[gcc/x86_64-pc-nto-qnx7.1.0/8.3.0/cc1plus]=x86_64-pc-nto-qnx7-g++ \
[usr/lib/gcc/x86_64-linux-gnu/12/cc1]=native-gcc \
)

function help() {
	echo "This binary translates 'special' compilers in compile_commands.json"
	echo "that clion does not recognize, to some 'well-known' compliers."
	echo ""
	echo "It does it by creating set of fake, 'well-known' compilers in './fakes'"
	echo "and changing compil_commands.json to use them."
	echo ""
	echo "It accepts list of compilers that are not recognized by CLion via --compilers arg."
	echo "Example of 'compilers-to-replace.txt:"
	echo "   /home/michal/work/tieto/pasa/sg3/tools/qnx710/host/linux/x86_64/usr/bin/qcc"
	echo "   /home/michal/work/tieto/pasa/sg3/tools/qnx710/host/linux/x86_64/usr/bin/q++"
	echo ""
	echo "This script would scan compile_commands.json and replace every occurence of"
	echo "binary from file passed via --compilers arg (qcc/q++ in the example)"
	echo "and replace it with 'known' compiler, according to MAP array (gcc/g++)"
}


# Define input_file and compilers_file variables
while [[ $# -gt 0 ]]; do
  case "$1" in
    --input)
      input_file="$2"
      shift 2
      ;;
    --compilers)
      compilers_file="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      help
      exit 1
      ;;
  esac
done

# Check if input_file and compilers_file are provided
if [ -z "$input_file" ] || [ -z "$compilers_file" ]; then
  echo "--input and --compilers arguments are required."
  exit 1
fi

# Read compilers from file into COMPILERS array
readarray -t COMPILERS < "$compilers_file"

# Extract binary names of compilers

BINARIES=()
for compiler in "${COMPILERS[@]}"; do
	binary=""
#	compiler="$(realpath $compiler)"
	for key in "${!MAP[@]}"; do
		if [[ "$compiler" == *"$key" ]]; then
			echo "translate $compiler --> ${MAP[$key]}"
			binary="${MAP[$key]}"
			break
		fi
	done
	if [ -z "$binary" ]; then
		echo "undefined translation for $compiler, edit MAP array"
	fi
	BINARIES+=($binary)
done

echo "press ENTER to continue"
read


FAKES_DIR="`pwd`/fakes"

# Replace compilers with their binary names
for i in "${!COMPILERS[@]}"; do
	echo "replacing ${COMPILERS[i]}  -->  ${FAKES_DIR}/${BINARIES[i]}"
	sed -i "s|${COMPILERS[i]}\"|${FAKES_DIR}/${BINARIES[i]}\"|g" "$input_file"
done

mkdir ${FAKES_DIR} -p
cd "$FAKES_DIR"
for i in "${!COMPILERS[@]}"; do
  ln -s ${COMPILERS[i]} ${BINARIES[i]} -f
done
