#!/bin/bash

ruby gen_ics.rb -t 2138 -s 5331 -m 0 -n "Ljusröd Medel B"
ruby gen_ics.rb -t 2138 -s 5206 -m 0 -n "Ljusröd Medel Mellersta"
ruby gen_ics.rb -t 2138 -s 5205 -m 0 -n "Ljusröd Medel Norra"
ruby rmagick.rb PPLMB_JärfällaIBK.ics "PPLMM_JärfällaIBK(B).ics" "PPLMN_JärfällaIBK(A).ics"
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/järfällaibk.pdf
