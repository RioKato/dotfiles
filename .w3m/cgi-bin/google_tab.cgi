#!/usr/bin/env sh

cat <<END
w3m-control: BACK
w3m-control: TAB_GOTO https://www.google.com/search?q=$QUERY_STRING
END
