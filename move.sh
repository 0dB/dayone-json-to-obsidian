for f in ./*.md; do
     # remove leading ./
     d=${f#./}
     # get YYYY and make directory (if it does not exist)
     Y=${d%%-*} # removes everything after first '-'
     mkdir -p $Y
     # get YYYY-MM and make directory (if it does not exist).
     # This can probably be done with one line instead of two.
     YMX=${d%-*} # removes everything after last '-'
     YM=${YMX%-*} # one more time, now we have YYYY-MM
     # move YYYY-MM into YYYY folder
     folder=$Y/$YM
     mkdir -p $folder
     # move file into YYYY/YYYY-MM folder
     # use foo="$foo"' world'?
     # put double quotes around variable substitutions and command substitutions?
     # word1=’ball’; word2=’park’; compound="$word1$word2″
     # Single quotes are "hard" in the shell, meaning that things like $… and ` (backtick expressions)
     # are not interpolated into them.
     # You cannot have spaces around your = in shell variable assignments.
     mv $f $folder
done
