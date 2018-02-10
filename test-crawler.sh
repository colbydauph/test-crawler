#!/bin/bash

# # # # # vars # # # # #
CWD=$(pwd)
DEV_DIR=${1:-$CWD}


# # # # # utils # # # # #

color() {
  printf "\033[0;$1m$2\033[0m"
}
red() {
  color 31 "$1"
}
green() {
  color 32 "$1"
}
yellow() {
  color 33 "$1"
}
bold() {
  color 1 "$1"
}
printResult() {
  (( $1 )) && red "✗" || green "✓"
}
printCol() {
  printf "%-$1s" "$2"
  printf ' | '
}
source_env() {
  if [ -f $1/.env ]; then
    . .env
  elif [ -f $REPO_DIR/.env.sh ]; then
    . .env.sh
  fi
}


# # # # # logic # # # # #
START_TIME=`date +%s`

echo ""
printCol 40 $(bold repo)
printCol 15 $(bold tool)
printCol 14 $(bold time)
printf $(bold ok)
echo -e "\n--------------------------------------------------"

FAIL_COUNT=0;
for REPO_DIR in `find $DEV_DIR -type d -mindepth 1 -maxdepth 1`
do
  REPO_NAME=$(basename $REPO_DIR)
  
  REPO_START_TIME=`date +%s`
  printCol 30 $REPO_NAME

  cd $REPO_DIR
  source_env $REPO_DIR

  # makefile
  if [ -f $REPO_DIR/makefile ]; then
    printCol 5 make
    printf "... "
    make test &> /dev/null

  # node.js / npm
  elif [ -f $REPO_DIR/package.json ]; then
    printCol 5 npm
    printf "... "
    npm test &> /dev/null

  # scala / sbt
  elif [ -f $REPO_DIR/build.sbt ]; then
    printCol 5 scala
    printf "... "
    sbt test &> /dev/null

  # ruby / rake
  elif [ -f $REPO_DIR/Rakefile ]; then
    printCol 5 ruby
    printf "... "
    rake test &> /dev/null  

  # shell
  elif [ -f $REPO_DIR/test.sh ]; then
    printCol 5 shell
    printf "... "
    ./test.sh &> /dev/null    

  else
    printCol 5 " "
    printCol 4 "0s"
    yellow "?\n"
    continue
  fi
  
  RESULT=$?
  
  printf "\b\b\b\b"
  REPO_RUNTIME=$(( `date +%s` - REPO_START_TIME ))
  (( $RESULT )) && ((FAIL_COUNT++))
  printCol 4 "${REPO_RUNTIME}s"
  printResult $RESULT
  echo ""
done

echo -e "--------------------------------------------------"

RUNTIME=$(( `date +%s` - START_TIME ))

cd $CWD
(( $FAIL_COUNT )) && \
  red "$FAIL_COUNT repos failed in ${RUNTIME}s" || \
  green "All repos passed in ${RUNTIME}s"

echo -e "\n"
exit $FAIL_COUNT