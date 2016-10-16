#!/bin/bash

ruby gen_ics.rb 17465 5195
ruby gen_ics.rb 17466 5197
ruby rmagick.rb PPLS_FarstaIBK.ics PPLMS_FarstaIBK.ics
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/farsta.pdf
