#! /bin/sh

if [ "$(id -u)" -ne "0" ]
then
	echo "Run this script as root." >&2
	exit 1
fi

if [ -z "$1" ]
then
	echo "Usage: $0 installation-directory"
	exit 1
fi

mkdir -p $1/bin
cp bin/* $1/bin

cp import.sh pp-collection-license.txt README.md env.example.sh config.example.json $1

echo "Files installed in directory $1."
echo "Fix permissions, if necessary."
echo "Remember also to modify config.example.json and env.example.sh files."
