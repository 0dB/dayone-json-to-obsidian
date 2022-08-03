function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }

BEGIN {
  mode = "NONE"
  filecontent = ""	
  FS = ":"
}

# TODO. To make this script more robust, add a check if EOFEOFEOFEOF only occurs directly before
# REFERENCE (or as last item).

/^REFERENCE/    { mode = "REFERENCE"; next }
/^METADATA/     { mode = "METADATA"; next }
/^CONTENT/      { mode = "CONTENT"; next }
/^EOFEOFEOFEOF/ { mode = "EOF"
  outputfile = creationDate "-" dayoneuuid ".md"
  print filecontent > outputfile
  close(outputfile)
  filecontent = ""
  next
}

# The first block, REFERENCE, is basically a lookup table for resolving 'identifiers' with actual
# file names. Key is 32 alphanumeric digits followed by colon. Some versions of awk do not allow 
# for {32} to specify length. Fields 5 (original file) and 6 (orderInEntry) are not used so far.

# /^[A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9][A-F0-9]:/

/^[a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9][a-zA-Z0-9]:/ {
  if (mode == "REFERENCE") {
    attachment[$1] = $2 FS $3 FS $4 FS $5 FS $6
    next
  }
}

# We use creationDate and dayone-uuid to generate a unique file name for each entry.
# TODO. Use timezone to turn time from UTC to the time zone of the entry.
# Is truncated to YYYY-MM-DDTHH because of FS being ":".

/creationDate/ { if (mode == "METADATA") {
    filecontent = filecontent RS $0
    creationDate = ltrim($2) # Just add more fields if MM:SS is also needed.
    next
  }
}

/dayone-uuid/ { if (mode == "METADATA") {
    filecontent = filecontent RS $0
    dayoneuuid = ltrim($2)
    next
  }
}

# Photos. Original filename is provided for the last few years, for the earlier years not.
# Not using this field so far. Videos. Same. Not using orginal filename, even when available.
# Audios. Compared to photos and videos, no ‘type’ stored, so extension is hard-coded to “m4a”.
# PDFs. Same pattern as photos and videos. Original filename is provided, but not using it.

# TODO. Consider renaming files using the identifier as the file name instead of the MD5 hash.

/^!\[\]\(dayone-moment:\/[^\/]*\// {
  # get identifier in array[3]
  split( $0, array, "[/)]" )
  # lookup stored path, md5 string (the actual filename) and type, using identifier 
  split( attachment[array[3]], filename, ":" )
  # special handling for audios
  if (filename[1] == "audios") { filename[3] = "m4a" }
  # alias will simply be PDF, GIF, PNG, JPG, M4A, ...
  alias = toupper(filename[3])
  filecontent = filecontent RS "![" alias "](" filename[1] "/" filename [2] "." filename[3] ")"
  next
}

# The main content and METADATA (which is "Front-matter" in Obsidian. Currently only "tags" are
# actually used by Obsidian.)
# First entry must not be preceded with RS, else we have a blank line at the start of every entry.

{ if (mode == "CONTENT" || mode == "METADATA") {
    if (filecontent != "") { filecontent = filecontent RS }
    filecontent = filecontent $0
    next
  }
}
