#!/bin/sh

tmux \
  send "`which python python3 python2 | head -n 1` -c 'import pty;pty.spawn(\"/bin/bash\")'" Enter \;\
  run "sleep 0.5" \;\
  send C-z \;\
  send "stty raw -echo" Enter \;\
  send "fg" Enter \;\
  send "reset" Enter \;\
  send "export TERM=xterm" Enter \;\
  run "tmux send \"stty rows #{pane_height} columns #{pane_width}\" Enter"
