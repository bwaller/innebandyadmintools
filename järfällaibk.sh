#!/bin/bash

ruby gen_ics.rb 2138 5331
ruby gen_ics.rb 2138 5206
ruby gen_ics.rb 2138 5205
ruby rmagick.rb PPLMB_JärfällaIBK.ics "PPLMM_JärfällaIBK(B).ics" "PPLMN_JärfällaIBK(A).ics"
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/järfällaibk.pdf
