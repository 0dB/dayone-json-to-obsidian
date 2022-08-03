# No "A" lines (UUIDs already in use in the vault) are outputted. Only "B" lines, and only if actually new.

BEGIN {
  FS = ":"
  isfirstline = 1
  print "{ entries : [.entries[] | select(.uuid | contains("
}

END {
  print "))]}"
}

# If "B" line (UUID from latest export), and it is really new (and not already in vault), output line.

$2 ~ /B/ {
  if ($1 != lastuuid) {
    output = "\"" $1 "\""
    if ( isfirstline == 0 ) { print "," output }
    else { print " " output }
    isfirstline = 0
  }
}

# Remember the UUID for the next line.

{ lastuuid = $1 }
