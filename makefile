# New notes and attachments will be added to the existing ones.

.PHONY: move all markdown prepare

all: prepare markdown move

prepare:
	mv -f Journal.json Backup.json
	unzip *.zip
	rm *.zip

markdown: Import.json ~/dayone-json-to-obsidian/journal.jq ~/dayone-json-to-obsidian/journal.awk
	jq -r -f ~/dayone-json-to-obsidian/journal.jq < Import.json | awk -f ~/dayone-json-to-obsidian/journal.awk

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
