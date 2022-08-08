# Put ZIP file from Day One export into vault directory.
# Call 'make initial' for first import from Day One.
# After that call 'make' (target will be 'all' since it is the first target) to add
# new notes and attachments to the existing ones.
# For updates, only need to export new entries, with some overlap to be safe.
# Scripts will check for overlaps and ignore known UUIDs.
# Scripts assume directory with scripts is parallel to vault directory, so run in vault
# directory and maybe have soft link in vault directory with:
# ln -s ~/dayone-json-to-obsidian/makefile makefile

.PHONY: move all update backup unzip import initial uuids split

all: backup unzip update split move

initial: unzip import split move

backup: Journal.json
	mv -f Journal.json Backup.json

# -n unzips without overwriting existing files (attachments) and without asking

unzip:
	unzip -n *.zip
	rm *.zip

# Get list of latest UUIDs
# Get all currently used IDs in Day One Export folder of Obsidian vault and append ":A" for further processing steps.
# Get all new UUIDs and append ":B" for further processing.
# Note: '-n' suppresses printing, "p" selectively prints

uuids: Journal.json
	find Day\ One\ Export | sed -n 's;Day One Export/..../....-../....-..-..T..-\([0-9A-F]*\).md;\1:A;p' > uuids.OLD
	jq -r '.entries[].uuid + ":B"' < Journal.json > uuids.NEW

# Compare the old and new UUIDs and filter by the new UUIDs, creating script at the same time

update.jq: uuids ~/dayone-json-to-obsidian/update.awk
	cat uuids.NEW uuids.OLD | sort | awk -f ~/dayone-json-to-obsidian/update.awk > update.jq

# Filter the new JSON file by just the UUIDs actually new to this vault

Update.json: update.jq Journal.json
	jq -r -f update.jq < Journal.json > Update.json

# Targets for creating long markdown file from .json file

import: Journal.json ~/dayone-json-to-obsidian/journal.jq
	jq -r -f ~/dayone-json-to-obsidian/journal.jq < Journal.json > EXPORT

update: Update.json ~/dayone-json-to-obsidian/journal.jq
	jq -r -f ~/dayone-json-to-obsidian/journal.jq < Update.json > EXPORT

# Split long markdown file into separate markdown files

split: EXPORT ~/dayone-json-to-obsidian/journal.awk ~/dayone-json-to-obsidian/journal.sed
	sed -f ~/dayone-json-to-obsidian/journal.sed < EXPORT | awk -f ~/dayone-json-to-obsidian/journal.awk

# Move the markdown files into subdirectories using filenames

move: ~/dayone-json-to-obsidian/move.sh
	sh ~/dayone-json-to-obsidian/move.sh
