#!/bin/bash

ruby gen_ics.rb 494 5195 0
ruby gen_ics.rb 484 5331 0
ruby rmagick.rb PPLS_EkeröIK.ics "PPLMB_EkeröIK(A).ics"
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröik_P02.pdf
