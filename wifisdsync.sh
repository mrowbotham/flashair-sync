#!/opt/bin/bash

DESTDIR="/volume1/Media/Pictures/pupplettedslr"
MINIP=106
MAXIP=108

mkdir -p "$DESTDIR"

download () {
  CURRENTDIR=$1
  BASEURL="http://192.168.0.$2"
  URL="$BASEURL/command.cgi?op=100&DIR=$CURRENTDIR"
  RESULT="$(curl -s -f -m 5 "$URL")"
  if [ ! -z "${RESULT}" ] ; then
    for LINE in $RESULT; do
      LASTSUCCESS=$2
      CELLS=(${LINE//,/ })
      if [ "${#CELLS[@]}" -gt 3 ]; then
          FILENAME=${CELLS[1]}
          FILEATTR=${CELLS[3]}
          FILESIZE=${CELLS[2]}
          if [ "${FILEATTR}" -eq "32" ]; then
            if [ ! -e "$DESTDIR/$FILENAME" ]; then
              RESULT="$(curl -s -f -m 600 -o "$DESTDIR/.tmp.bin" "$BASEURL/$CURRENTDIR/$FILENAME" -w %{size_download})"
              if [ "${RESULT}" -eq "$FILESIZE" ] ; then
                mv "$DESTDIR/.tmp.bin" "$DESTDIR/$FILENAME"
              else
                break
              fi
            fi
          elif [ "${FILEATTR}" -eq "16" ]; then
            download "$CURRENTDIR/$FILENAME" "$2"
          fi
      fi
   done
  fi
}

i=$MINIP
while true
do
   if [ -z "$LASTSUCCESS" ]; then
     LASTSUCCESS=
     download "DCIM" "$i"
     i=$((i+1))
     if [ "$i" -gt "$MAXIP" ]; then
       i=$MINIP
     fi
   else
     echo "LASTSUCCESS download $LASTSUCCESS"
     download "DCIM" "$LASTSUCCESS"
   fi
   sleep 10
done
