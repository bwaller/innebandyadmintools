#!/bin/bash

ruby gen_ics.rb -t 17465 -s 5195 -m 0 -n "Ljusröd Svår"
ruby gen_ics.rb -t 17466 -s 5197 -m 0 -n "Ljusröd Medelsvår Södra"
ruby rmagick.rb PPLS_FarstaIBK.ics PPLMS_FarstaIBK.ics
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/farsta.pdf
