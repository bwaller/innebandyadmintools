#!/bin/bash

ruby gen_ics.rb 2180 5195
ruby gen_ics.rb 2181 5331
ruby rmagick.rb PPLS_HässelbySKIBK.ics PPLMB_HässelbySKIBK.ics
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/hsk.pdf
