#!/bin/bash

# Script made by macr1408 (https://github.com/macr1408)
# Made for non Commercial use

CURRENTDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
CONFIGFILE="$CURRENTDIR/config.sh"
REFRESHFILE="$CURRENTDIR/refresh_accesstoken.sh"
SONGFILE="$CURRENTDIR/current_song.json"
source $CONFIGFILE

curl -s https://api.spotify.com/v1/me/player/currently-playing \
-H "Authorization: Bearer $ACCESSTOKEN" \
-o $SONGFILE

ERRORCODE=$(jq -r '.error.status' $SONGFILE)
ERRORMSG=$(jq -r '.error.message' $SONGFILE)
if [ $ERRORCODE == 401 ] && [ "$ERRORMSG" == "The access token expired" ]
then
    source $REFRESHFILE
fi
ARTIST=$(jq -r '.item.artists[0].name' $SONGFILE)
TRACK=$(jq -r '.item.name' $SONGFILE)
ALBUM=$(jq -r '.item.album.name' $SONGFILE)
SONGLINK=$(jq -r '.item.external_urls.spotify' $SONGFILE)
CURRENTPROGRESS=$(jq -r '.progress_ms' $SONGFILE)
CURRENTPROGRESS=$(expr $CURRENTPROGRESS \* 100)
TOTALPROGRESS=$(jq -r '.item.duration_ms' $SONGFILE)
TOTALPROGRESS=$(expr $CURRENTPROGRESS / $TOTALPROGRESS )

if [ -n "$TRACK" ]
then
echo "<txt>$ARTIST - $TRACK  </txt>"
echo "<tool>$ALBUM</tool>"
echo "<bar>$TOTALPROGRESS</bar>"
echo "<txtclick>exo-open $SONGLINK</txtclick>"
else
echo "<txt></txt>"
fi