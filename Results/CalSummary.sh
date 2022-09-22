# /usr/bin

declare -a dirs
dirs=("CreateTasksWithKey")

function CalAvg(){
  for fileName in *summary*; do
    echo $fileName
  done
}

for dir in ${dirs[@]}; do
  cd $(echo $dir)
  CalAvg
done
