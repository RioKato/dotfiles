#!/usr/bin/env sh

cat <<END
w3m-control: BACK
w3m-control: GOTO https://www.google.com/search?gl=ja&hl=ja&q=$QUERY_STRING
END
