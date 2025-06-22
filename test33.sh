#!/bin/sh

if [ "$1" = "y" ]
then
	var1="y"
else
	var1="n"
fi
if [ "$2" = "y" ]
then
	var2="y"
else
	var2="n"
fi
echo "var1 = $var1, var2 = $var2"