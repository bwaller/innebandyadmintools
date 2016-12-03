#!/bin/bash

ruby gen_ics.rb -t 494 -s 5195 -m 0 -n "P02 Ljusröd Svår"
ruby gen_ics.rb -t 484 -s 5331 -m 0 -n "P02 Ljusröd Medel B"
ruby gen_ics.rb -t 13559 -s 5246 -m 0 -n "P06 Blå Medel Lätt B"
ruby gen_ics.rb -t 13561 -s 5251 -m 0 -n "P06 Blå Lätt Svår B"
ruby rmagick.rb PPLS_EkeröIK.ics "PPLMB_EkeröIK(A).ics" "PPBMLB_EkeröIK.ics" "PPBLSB_EkeröIK.ics"
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröik_P02P06.pdf
