#!/bin/bash

ruby gen_ics_venue.rb 1256  > farstahallen1.ics
ruby gen_ics_venue.rb 1258  > farstahallen3.ics

ruby rmagick.rb farstahallen1.ics farstahallen3.ics
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/farstahallarna.pdf
