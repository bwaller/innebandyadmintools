#!/bin/bash

ruby gen_ics.rb -t 494 -s 5195 -m 0 -n "P02 Ljusröd Svår"
ruby gen_ics.rb -t 484 -s 5331 -m 0 -n "P02 Ljusröd Medel B"
ruby gen_ics.rb -t 492 -s 5240 -m 0 -n "P05 Blå Svår Lätt Södra"
ruby gen_ics.rb -t 19339 -s 5242 -m 0 -n "P05 Blå Medel Svår B"
ruby rmagick.rb "PPBMSB_EkeröIK.ics" "PPBSLS_EkeröIK(C).ics" PPLS_EkeröIK.ics "PPLMB_EkeröIK(A).ics" 
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröik_P02P05.pdf
