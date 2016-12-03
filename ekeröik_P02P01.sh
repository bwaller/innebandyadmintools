#!/bin/bash

ruby gen_ics.rb -s 5195 -t 494 -m 0 -n "P02 Ljusröd Svår"
ruby gen_ics.rb -s 5331 -t 484 -m 0 -n "P02 Ljusröd Medel B"
ruby gen_ics.rb -s 5186 -t 481 -m 0 -n "P01 Mörkröd Svår"
ruby gen_ics.rb -s 5191 -t 19337 -m 0 -n "P01 Mörkröd Medel Mellersta"
ruby rmagick.rb PPMS_EkeröIK.ics PPMMM_EkeröIK.ics PPLS_EkeröIK.ics "PPLMB_EkeröIK(A).ics" 
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröik_P02P01.pdf

