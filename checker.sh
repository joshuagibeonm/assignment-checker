#!/bin/bash
#filename: alpro.sh
#author: gibeon@joshuagibeon

#Redirect all stderr to null
exec 2>/dev/null

function environmentPrepare(){
  while true; do
    read -p "Do you wish to prepare the enviroment for this program? [Y/N]" yn
    case $yn in
        [Yy]* ) break;;
        [Nn]* ) exit;;
        * ) echo "Please answer yes or no.";;
    esac
  done

  echo -n "[`date +'%H:%M:%S'`] Checking filelist folder "
  if [ -d filelist ]; then
    echo "[FOUND]"
  else
    echo "[NOT FOUND]"
    echo -n "[`date +'%H:%M:%S'`] Creating filelist folder "
    mkdir filelist
    echo "[DONE]"
  fi

  echo -n "[`date +'%H:%M:%S'`] Checking testcase folder "
  if [ -d testcase ]; then
    echo "[FOUND]"
  else
    echo "[NOT FOUND]"
    echo -n "[`date +'%H:%M:%S'`] Creating testcase folder "
    mkdir testcase
    echo "[DONE]"
  fi

  echo -n "[`date +'%H:%M:%S'`] Checking answer folder "
  if [ -d answer ]; then
    echo "[FOUND]"
  else
    echo "[NOT FOUND]"
    echo -n "[`date +'%H:%M:%S'`] Creating answer folder "
    mkdir answer
    echo "[DONE]"
  fi

  echo -n "[`date +'%H:%M:%S'`] Checking output folder "
  if [ -d output ]; then
    echo "[FOUND]"
  else
    echo "[NOT FOUND]"
    echo -n "[`date +'%H:%M:%S'`] Creating output folder "
    mkdir output
    echo "[DONE]"
  fi
  echo "Please Read the README file again and then re-run the script"
  exit
}


#Function to check if the environment is ready or not
#if the environment is not ready, the script will prompt
#the user and then ask the user if he wants to prepare
#the environment or not
function environmentCheck () {
  echo -n "[`date +'%H:%M:%S'`] Checking filelist folder "
  if [ -d filelist ]; then
    echo "[FOUND]"
  else
    echo "[NOT FOUND]"
    environmentPrepare
    exit
  fi

  echo -n "[`date +'%H:%M:%S'`] Checking testcase folder "
  if [ -d testcase ]; then
    echo "[FOUND]"
  else
    echo "[NOT FOUND]"
    environmentPrepare
    exit
  fi

  echo -n "[`date +'%H:%M:%S'`] Checking answer folder "
  if [ -d answer ]; then
    echo "[FOUND]"
  else
    echo "[NOT FOUND]"
    environmentPrepare
    exit
  fi

  echo -n "[`date +'%H:%M:%S'`] Checking output folder "
  if [ -d output ]; then
    echo "[FOUND]"
  else
    echo "[NOT FOUND]"
    environmentPrepare
    exit
  fi
}

function assignment-checker(){
  #Get Title Name for scoresheet log
  TITLE=$1
  TITLE=${TITLE:="NO TITLE"}

  #Compile answer source code
  echo -n "[`date +'%H:%M:%S'`] Compiling answer.cpp "
  gcc answer.cpp -o answerexe
  CHECK=$?
  if [ $CHECK != 0 ]; then
    echo "[ERROR] : $CHECK"
    exit
  else
    echo "[OK]"
  fi


  #Get testcase listname
  echo -n "[`date +'%H:%M:%S'`] Getting testcase listname "
  TESTCASE=`ls --format=single-column ./testcase`
  MAX=`ls -1 testcase | wc -l`
  CHECK=$?
  if [ $CHECK != 0 ]; then
    echo "[ERROR] : $CHECK"
    exit
  else
    echo "[OK]"
  fi


  #Get correct answer from key
  echo "[`date +'%H:%M:%S'`] Get correct answer from answer source code"
  for tc in $TESTCASE; do
    echo -n "[`date +'%H:%M:%S'`] Get answer from $tc "
    ./answerexe < testcase/${tc} > answer/${tc}
    CHECK=$?
    if [ $CHECK != 0 ]; then
      echo "[ERROR] : $CHECK"
      exit
    else
      echo "[OK]"
    fi
  done
  echo "[`date +'%H:%M:%S'`] Get correct answer from answer source code [DONE]"


  #Check student's answer
  echo -n "[`date +'%H:%M:%S'`] Get student's source code "
  FILELIST=`ls --format=single-column ./filelist`
  CHECK=$?
  if [ $CHECK != 0 ]; then
    echo "[ERROR] : $CHECK"
    exit
  else
    echo "[OK]"
  fi


  #Check if the answer is correct or not
  echo "----$TITLE----" >> scoresheet.log
  for fl in $FILELIST; do
    NIM=`echo $fl | cut -d _ -f 2 | cut -d . -f 1`
    echo "[`date +'%H:%M:%S'`] --Checking $NIM answer--"

    echo -n "[`date +'%H:%M:%S'`] $NIM: Compiling "
    gcc ./filelist/${fl} -o ${fl}exe
    CHECK=$?
    if [ $CHECK != 0 ]; then
      echo "[ERROR] : $CHECK"
      echo "${NIM}-${POINT}/${MAX}" >> scoresheet.log
      echo "[`date +'%H:%M:%S'`] --Checking $NIM answer [DONE]--"
      continue
    else
      echo "[OK]"
    fi

    POINT=0

    for tc in $TESTCASE; do
      echo -n "[`date +'%H:%M:%S'`] $NIM-${tc}: Executing "
      ./${fl}exe < testcase/${tc} > output/${tc}
      if [ $CHECK != 0 ]; then
        echo "[ERROR] : $CHECK"
        continue
      else
        echo "[OK]"
      fi

      diff -iad output/${tc} answer/${tc}
      CHECK=$?
      if [ $CHECK != 0 ]; then
        echo "[`date +'%H:%M:%S'`] ${NIM}-${tc}: ANSWER [WRONG]"
      else
        echo "[`date +'%H:%M:%S'`] ${NIM}-${tc}: ANSWER [OK]"
        POINT=`expr $POINT + 1`
      fi
    done

    echo "${NIM}-${POINT}/${MAX}" >> scoresheet.log
    echo "[`date +'%H:%M:%S'`] --Checking $NIM answer [DONE]--"
    rm output/*
    rm ${fl}exe
  done
  rm answerexe
  rm answer/*
}

environmentCheck
assignment-checker
