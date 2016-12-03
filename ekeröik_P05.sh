#!/bin/bash

ruby gen_ics.rb -t 492 -s 5240 -m 0 -n "Blå Svår Lätt Södra"
ruby gen_ics.rb -t 19339 -s 5242 -m 0 -n "Blå Medel Svår B"
ruby rmagick.rb "PPBSLS_EkeröIK(C).ics" "PPBMSB_EkeröIK.ics"
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröik_P05.pdf
