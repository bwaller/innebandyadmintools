#!/bin/bash

ruby gen_ics.rb -t 2411 -s 5195 -m 0 -n "Ljusröd Svår" 
ruby gen_ics.rb -t 2412 -s 5331 -m 0 -n "Ljusröd Medel B"
ruby rmagick.rb PPLS_BeleBarkarbyIFIBF.ics PPLMB_BeleBarkarbyIFIBF.ics
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/belebarkarbyibf.pdf
