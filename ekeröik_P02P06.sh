#!/bin/bash

ruby gen_ics.rb 494 5195 0
ruby gen_ics.rb 484 5331 0
ruby gen_ics.rb 13559 5246 0
ruby gen_ics.rb 13561 5251 0
ruby rmagick.rb PPLS_EkeröIK.ics "PPLMB_EkeröIK(A).ics" "PPBMLB_EkeröIK.ics" "PPBLSB_EkeröIK.ics"
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröik_P02P06.pdf
