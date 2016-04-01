#!/usr/bin/env fish
set BASE_DIR (cd (dirname (status -f)); and pwd)

eval $BASE_DIR/check.sh | grep missing
eval $BASE_DIR/dots.sh > /dev/null


set LOCAL_FIST_CONFIG "$HOME/.config/fish/config.fish.local"
if test ! -e $LOCAL_FIST_CONFIG
  touch $LOCAL_FIST_CONFIG
end

. "$HOME/.config/fish/config.fish"
