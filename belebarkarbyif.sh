#!/bin/bash

ruby gen_ics.rb 2411 5195
ruby gen_ics.rb 2412 5331
ruby rmagick.rb PPLS_BeleBarkarbyIFIBF.ics PPLMB_BeleBarkarbyIFIBF.ics
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/belebarkarbyibf.pdf
