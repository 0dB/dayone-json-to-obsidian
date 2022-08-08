for f in ./20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]T[0-9][0-9]-*.md; do
     prefix='Day One Export'
     mkdir -p "${prefix}"
     # remove leading ./
     # You cannot have spaces around your = in shell variable assignments.
     d=${f#./}
     # get YYYY and make directory (if it does not exist)
     Y=${d%%-*} # removes everything after first '-'
     mkdir -p "${prefix}/$Y"
     # get YYYY-MM and make directory (if it does not exist).
     # This can probably be done with one line instead of two.
     YMX=${d%-*} # removes everything after last '-'
     YM=${YMX%-*} # one more time, now we have YYYY-MM
     # move YYYY-MM into YYYY folder
     folder=$Y/$YM
     mkdir -p "${prefix}/${folder}"
     # move file into YYYY/YYYY-MM folder
     mv $f "${prefix}/$folder"
done
