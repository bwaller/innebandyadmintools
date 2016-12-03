#!/bin/bash

ruby gen_ics.rb -t 2180 -s 5195 -m 0 -n "HSK P02 Ljusröd Svår"
ruby gen_ics.rb -t 2181 -s 5331 -m 0 -n "HSK P02 Ljusröd Medel B"
ruby rmagick.rb PPLS_HässelbySKIBK.ics PPLMB_HässelbySKIBK.ics
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/hsk.pdf
