#!/bin/bash

FILE_PATTERN=""
SINCE_DATE=""

for i in "$@"
do
case $i in
    --filePattern=*)
      ENTERED_PATTERN="${i#*=}"
      FILE_PATTERN="-name $ENTERED_PATTERN"
      shift # past argument=value
    ;;
    --sinceDate=*)
      ENTERED_DATE="${i#*=}"
      SINCE_DATE="--after=$ENTERED_DATE"
      shift # past argument=value
    ;;
    *)
      usage    # unknown option
      exit 1
    ;;
esac
done


for FILE_NAME in $(find . $FILE_PATTERN -print);
do
	NUM_CHANGES=$(git log --oneline $SINCE_DATE -- $FILE_NAME | wc -l)
	echo "$NUM_CHANGES,$FILE_NAME"
done
