#!/bin/bash

ruby gen_ics.rb -t 494 -s 5195 -m 0 -n "EIK P02 Ljusröd Svår"
ruby gen_ics.rb -t 484 -s 5331 -m 0 -n "EIK P02 Ljusröd Medel B"
ruby rmagick.rb PPLS_EkeröIK.ics "PPLMB_EkeröIK(A).ics"
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröik_P02.pdf
