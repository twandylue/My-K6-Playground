#!/bin/bash

declare -a rateArray
function FindRateArray(){
  for fileName in *_summary_[0-9]Pods_R[0-9]*_D*; do
    [ -e "${fileName}" ] || continue
    rateNumber=$(echo ${fileName} | grep -o "R\d*" | grep -o "\d*") 
    if [[ $rateNumber == "" ]]; then
      continue
    fi

    ## 寫法1
    # if [[ " ${rateArray[*]} " =~ " ${rateNumber} " ]]; then
    ## 寫法2
    if [[ $(echo ${rateArray[*]} | grep -o "$rateNumber" ) != "" ]]; then
      continue
    fi
    rateArray+=($rateNumber)
  done
}

function CalAvg(){
  for rateNumber in ${rateArray[*]}; do
    echo "================Rate:${rateNumber}================"
    count=0
    sumP90=0
    sumP95=0
    sumRate=0

    for fileName in *_summary_[0-9]Pods_R${rateNumber}_D*; do
      [ -e "${fileName}" ] || continue

      fails=$(cat $fileName | jq '.metrics.checks.fails')
      # echo "Condition: ${fileName}, Fails Req: ${fails}"
      # NOTE: failed cases would not be included into results
      if [[ "${fails}" != "0" ]]; then
          echo "Fail Condition: ${fileName}, Fails Req: ${fails}"
          continue
      fi
      passes=$(cat $fileName | jq '.metrics.checks.passes')

      echo $fileName
      count=$((count+1))
      p90=$(cat $fileName | jq '.metrics.http_req_duration."p(90)"')
      sumP90=$((${p90%\.*}+sumP90))
      p95=$(cat $fileName | jq '.metrics.http_req_duration."p(95)"')
      sumP95=$((${p95%\.*}+sumP95))
      rate=$(cat $fileName | jq '.metrics.http_reqs.rate')
      sumRate=$((${rate%\.*}+sumRate))
    done

    echo "-----"
    # echo $sumRate
    avgRate=$(bc <<< $sumRate/$count)
    echo "AvgRate:"
    echo $avgRate

    echo "-----"
    # echo $sumP90
    avgP90=$(bc <<< $sumP90/$count)
    echo "AvgP90:"
    echo $avgP90

    echo "-----"
    # echo $sumP95
    avgP95=$(bc <<< $sumP95/$count)
    echo "AvgP95:"
    echo $avgP95

    summary="Summary_R${rateNumber}.txt"
    if [[ -f "$summary" ]]; then
      rm $summary
    fi

    echo "AvgRate: $avgRate" >> Summary_R${rateNumber}.txt
    echo "AvgP90: $avgP90" >> Summary_R${rateNumber}.txt
    echo "AvgP95: $avgP95" >> Summary_R${rateNumber}.txt
  done
}

# directory name
declare -a dirs
if [[ $1 == "all" ]]; 
then
  for dir in */; do
    dirs+=($dir)
  done
else
  dirs=("CreateTasksWithKey_1Pods")
fi

for dir in ${dirs[*]}; do
  # using command in order to get the exit code
  command cd $(echo $dir)
  if [[ $? == "1" ]]; then
    # echo "Directory: $dir does not exist."
    exit 1
  fi
  FindRateArray
  CalAvg
  cd -
done
