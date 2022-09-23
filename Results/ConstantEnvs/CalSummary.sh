# /usr/bin
# set -x

declare -a dirs
# directory name
dirs=("CreateTasksWithKey_10Pods")

function CalAvg(){
  count=0
  sumP90=0
  sumP95=0
  sumRate=0

  for fileName in *summary*; do
    [ -e "${fileName}" ] || continue

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

  summary="Summary.txt"
  if [[ -f "$summary" ]]; then
    rm $summary
  fi

  echo "AvgRate: $avgRate" >> Summary.txt
  echo "AvgP90: $avgP90" >> Summary.txt
  echo "AvgP95: $avgP95" >> Summary.txt
}

for dir in ${dirs[@]}; do
  cd $(echo $dir)
  CalAvg
  cd -
done
