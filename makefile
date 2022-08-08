# Put ZIP file from Day One export into vault directory.
# Call 'make initial' for first import from Day One.
# After that call 'make' (target will be 'all' since it is the first target) to add
# new notes and attachments to the existing ones.
# For updates, only need to export new entries, with some overlap to be safe.
# Scripts will check for overlaps and ignore known UUIDs.
# Scripts assume directory with scripts is parallel to vault directory, so run in vault
# directory and maybe have soft link in vault direcory with:
# ln -s ~/dayone-json-to-obsidian/makefile makefile

.PHONY: move all markdown prepare

all: prepare markdown move

initial:
	unzip *.zip
	rm *.zip
	jq -r -f ~/dayone-json-to-obsidian/journal.jq < Journal.json | sed -f ~/dayone-json-to-obsidian/journal.sed | awk -f ~/dayone-json-to-obsidian/journal.awk
	sh ~/dayone-json-to-obsidian/move.sh

prepare:
	mv -f Journal.json Backup.json
	unzip *.zip
	rm *.zip

markdown: Import.json ~/dayone-json-to-obsidian/journal.jq ~/dayone-json-to-obsidian/journal.awk
	jq -r -f ~/dayone-json-to-obsidian/journal.jq < Import.json | sed -f ~/dayone-json-to-obsidian/journal.sed | awk -f ~/dayone-json-to-obsidian/journal.awk

move:
	sh ~/dayone-json-to-obsidian/move.sh

# Filter the new JSON file by just the UUIDs actually new to this vault

Import.json: update.jq Journal.json
	jq -r -f update.jq < Journal.json > Import.json

# Compare the old and new UUIDs and filter by the new UUIDs, creating script at the same time

update.jq: uuids.NEW uuids.OLD ~/dayone-json-to-obsidian/update.awk
	cat uuids.NEW uuids.OLD | sort | awk -f ~/dayone-json-to-obsidian/update.awk > update.jq

# Get list of latest UUIDs

uuids.NEW: Journal.json
	jq -r '.entries[].uuid + ":B"' < Journal.json > uuids.NEW

# Get all currently used IDs in Day One Export folder of Obsidian vault and append ":A" for further processing steps:
# Note: '-n' suppresses printing, "p" selectively prints

uuids.OLD:
	find Day\ One\ Export | sed -n 's;Day One Export/..../....-../....-..-..T..-\([0-9A-F]*\).md;\1:A;p' > uuids.OLD
