#!/bin/bash

ruby gen_ics.rb 492 5240 0
ruby gen_ics.rb 19339 5242 0
ruby rmagick.rb "PPBSLS_EkeröIK(C).ics" "PPBMSB_EkeröIK.ics"
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröik_P05.pdf
