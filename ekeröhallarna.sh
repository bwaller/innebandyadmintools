#!/bin/bash

ruby gen_ics_venue.rb -i 1260  > bollhallen.ics
ruby gen_ics_venue.rb -i 3080 --name "Mälaröhallen" > malarohallen.ics

ruby rmagick.rb bollhallen.ics malarohallen.ics
convert junk.png -crop 840x1188 -page 840x1188 /mnt/hgfs/Documents/ekeröhallarna.pdf
