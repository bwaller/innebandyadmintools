#!/bin/bash

ruby gen_ics_venue.rb 1260  > bollhallen.ics
ruby gen_ics_venue.rb 3080  > malarohallen.ics

ruby rmagick.rb bollhallen.ics malarohallen.ics
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröhallarna.pdf
