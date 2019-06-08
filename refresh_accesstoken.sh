#!/bin/bash

CURRENTDIR=$(dirname -- "$(readlink -f -- "$BASH_SOURCE")")
CONFIGFILE="$CURRENTDIR/config.sh"
REFRESHRES="$CURRENTDIR/refresh_results.json"
source $CONFIGFILE

curl -X POST https://accounts.spotify.com/api/token \
-H "Authorization: Basic $AUTHHEADER" \
-H "content-type: application/x-www-form-urlencoded" \
-d "grant_type=refresh_token&refresh_token=$REFRESHTOKEN" \
-o $REFRESHRES

NEWACCESSTOKEN=$(jq -r '.access_token' $REFRESHRES)

cat > $CONFIGFILE << EOL
#!/bin/bash

AUTHHEADER=${AUTHHEADER}
ACCESSTOKEN=${NEWACCESSTOKEN}
REFRESHTOKEN=${REFRESHTOKEN}
EOL

SONGFILE="$CURRENTDIR/current_song.json"

curl https://api.spotify.com/v1/me/player/currently-playing \
-H "Authorization: Bearer $NEWACCESSTOKEN" \
-o $SONGFILE