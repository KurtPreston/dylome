#dylome

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )

function float_eval() 
{
  float_scale=3
  local stat=0
  local result=0.0
  if [[ $# -gt 0 ]]; then
    result=$(echo "scale=$float_scale; $*" | bc -q 2>/dev/null)
    stat=$?
    if [[ $stat -eq 0  &&  -z "$result" ]]; then stat=1; fi
  fi
  echo $result
  return $stat
}

function float_cond()
{
  local cond=0
  if [[ $# -gt 0 ]]; then
    cond=$(echo "$*" | bc -q 2>/dev/null)
    if [[ -z "$cond" ]]; then cond=0; fi
    if [[ "$cond" != 0  &&  "$cond" != 1 ]]; then cond=0; fi
  fi
  local stat=$((cond == 0))
  return $stat
}

#deleting temporary files that might exist from previus executions.
rm -r $SCRIPTPATH/tempdylome
rm $SCRIPTPATH/outputfile.mp3
rm $SCRIPTPATH/piecelist.txt
mkdir $SCRIPTPATH/tempdylome

minutes=0
mySeconds=0
chunk=$1 
i=0
complete=0 #flag for the end of the process

displayChunk=$chunk
cond2="10.0 > $dispsec "
if float_cond $cond2; then
  displayChunk="0$displayChunk"
fi

while [ $complete -le 1 ]

do
  i=$[i+1]
  finame=dylomePiece$[10000-i]
  mySeconds=$(float_eval "$mySeconds + $chunk")

  cond="60.0 <= $mySeconds "
  if float_cond $cond; then
    mySeconds=$(float_eval "$mySeconds - 60.0")
    minutes=$[minutes+1]

  fi

  displyMinutes=$minutes
  if [ 10 -gt $minutes ]; then
    displyMinutes="0$displyMinutes"
  fi

  # fail safe. prevents the script to run forever in case of an error. 
  if [ $i -gt 1000  ]; then
    complete=10
  fi

  dispsec=$mySeconds
  cond2="10.0 > $dispsec "
  if float_cond $cond2; then
    dispsec="0$dispsec"
  fi
  ffmpeg -i $SCRIPTPATH/inputfile.mp3 -vcodec copy -acodec copy -ss 00:$displyMinutes:$dispsec -t 00:00:0$chunk $SCRIPTPATH/tempdylome/$finame.mp3

  #checking the file size of the chunk tht was generated. If it is too small we reached the end of the process.
  a=$(du -sk $SCRIPTPATH/tempdylome/$finame.mp3 |cut -f 1)
  if [ 5 -gt $a ]; then
    complete=10     
    rm $SCRIPTPATH/tempdylome/$finame.mp3
  fi
done

for f in $SCRIPTPATH/tempdylome/*.mp3
do
  echo "file '$f'" >> $SCRIPTPATH/piecelist.txt
done


./$SCRIPTPATH/ffmpeg -f concat -i $SCRIPTPATH/piecelist.txt -c copy $SCRIPTPATH/outputfile.mp3

#deletes temporary files.
rm -r $SCRIPTPATH/tempdylome
rm $SCRIPTPATH/inputfile.mp3
rm $SCRIPTPATH/piecelist.txt
