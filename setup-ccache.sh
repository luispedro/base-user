#!/usr/bin/env zsh
cd $VIRTUAL_ENV/bin

for link in c++ cc g++ gcc x86_64-linux-gnu-gcc x86_64-linux-gnu-g++ ; ln -fs `which ccache` $link
