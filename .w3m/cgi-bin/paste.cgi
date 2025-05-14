#!/usr/bin/env sh

echo 'w3m-control: BACK'

if [ "$XDG_SESSION_TYPE" = x11 ] || [ -z "$XDG_SESSION_TYPE" ]
then
  if command -v xsel >& /dev/null
  then
      echo "w3m-control: GOTO $(xsel -bo | head -n 1)"
  fi
fi

if [ "$XDG_SESSION_TYPE" = wayland ] || [ -z "$XDG_SESSION_TYPE" ]
then
  if command -v wl-copy wl-paste >& /dev/null
  then
      echo "w3m-control: GOTO $(wl-paste | head -n 1)"
  fi
fi
