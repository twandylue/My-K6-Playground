#! /bin/bash
# set -x

declare -a rateArray
function FindRateArray(){
  for fileName in *_summary_[0-9]Pods_R[0-9]*_D*; do
    [ -e "${fileName}" ] || continue
    # rateNumber=$(echo ${fileName} | grep -o "R\d*" | grep -o "\d*") 
    rateNumber=$(echo ${fileName} | grep -o "R[0-9]*" | grep -o "[0-9]*") 
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

declare -a durationArray
function FindDurationArray(){
  for fileName in *_summary_[0-9]Pods_R[0-9]*_D[0-9]*; do
    [ -e "${fileName}" ] || continue
    # durationTime=$(echo ${fileName} | grep -o "D\d*" | grep -o "\d*") 
    durationTime=$(echo ${fileName} | grep -o "D[0-9]*" | grep -o "[0-9]*") 
    if [[ $durationTime == "" ]]; then
      continue
    fi

    if [[ $(echo ${durationArray[*]} | grep -o "$durationTime" ) != "" ]]; then
      continue
    fi
    durationArray+=($durationTime)
  done
}

declare -a preAllocatedArray
function FindPreAllocatedArray(){
  for fileName in *_summary_[0-9]Pods_R[0-9]*_D[0-9]*s_P[0-9]*; do
    [ -e "${fileName}" ] || continue
    # preAllocatedNumber=$(echo ${fileName} | grep -o "P\d*" | grep -o "\d*") 
    preAllocatedNumber=$(echo ${fileName} | grep -o "P[0-9]*" | grep -o "[0-9]*") 
    if [[ $preAllocatedNumber == "" ]]; then
      continue
    fi

    if [[ $(echo ${preAllocatedArray[*]} | grep -o "$preAllocatedNumber" ) != "" ]]; then
      continue
    fi
    preAllocatedArray+=($preAllocatedNumber)
  done
}

declare -a maxVusArray
function FindMaxVusArray(){
  for fileName in *_summary_[0-9]Pods_R[0-9]*_D[0-9]*s_P[0-9]*_M[0-9]*; do
    [ -e "${fileName}" ] || continue
    # maxVusNumber=$(echo ${fileName} | grep -o "M\d*" | grep -o "\d*") 
    maxVusNumber=$(echo ${fileName} | grep -o "M[0-9]*" | grep -o "[0-9]*") 
    if [[ $maxVusNumber == "" ]]; then
      continue
    fi

    if [[ $(echo ${maxVusArray[*]} | grep -o "$maxVusNumber" ) != "" ]]; then
      continue
    fi
    maxVusArray+=($maxVusNumber)
  done
}

function CalAvg(){
  for durationTime in ${durationArray[*]}; do
    for rateNumber in ${rateArray[*]}; do
      for preAllocatedNumber in ${preAllocatedArray[*]}; do
        for maxVusNumber in ${maxVusArray[*]}; do
          echo "**********"
          echo "$durationTime"
          echo "$rateNumber"
          echo "$preAllocatedNumber"
          echo "$maxVusNumber"
          echo "**********"

          echo "================Rate:${rateNumber}================"
          count=0
          sumP90=0
          sumP95=0
          sumRate=0

          for fileName in *[0-9]_summary_[0-9]*Pods_R${rateNumber}_D${durationTime}s_P${preAllocatedNumber}_M${maxVusNumber}*; do
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

          outputFileName="$(echo ${fileName} | sed 's/[0-9]*_//1' | sed 's/.json//1').txt"
          if [[ -f "${outputFileName}" ]]; then
            rm ${outputFileName}
          fi

          echo "AvgRate: $avgRate" >> ${outputFileName}
          echo "AvgP90: $avgP90" >> ${outputFileName}
          echo "AvgP95: $avgP95" >> ${outputFileName}
        done
      done
    done
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
  FindDurationArray
  FindPreAllocatedArray
  FindMaxVusArray

  CalAvg
  cd -
done
