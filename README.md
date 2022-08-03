# Update Obsidian vault from Day One (“DayOne”) JSON using command line scripts

NEW: The scripts now also update the Obsidian vault with new Day One entries (those with new UUIDs). Preliminary tests look good. (TODO: Add documentation, change path for 'move' script.)

NOTE: Please only use these scripts if you have a grasp of what they do and they either do exactly what you need or you can edit them to your taste.

The Markdown files are named in the form `YYYY-MM-DDTHH-<Day One UUID>`.
A "title" inside the file is not used for the filename but can easily be added.
The files will be moved into YYYY/YYYY-MM directories which are created as needed.
All known Day One attachment types are supported. The script creates Wiki-style links of the form `[[Link]]`. Obsidian will find the files.

A description of the chosen approach, where each script does one thing, and each file is easy to read and understand and change:
  - The `.jq` script flattens the JSON file and creates a long Markdown file divided into segments for further processing. 
  Some segments will not appear in the final output but are solely for the following stages. Tags are processed and a meaningful set of Day One metadata is stored, but Obsidian will actually only make use of the tags.
  - The `.awk` script reads this file, uses the special data segments and the metadata for its own logic (creating filenames, replacing links to attachments), and creates one file per Day One entry.
  - the `.sh` script looks at the outputted `.md` files and creates folders of the form `YYYY/YYYY-MM` as needed and moves the files.

The `.md` files have metadata ("Front-matter" in Obsidian). The Day One UUID is in the filename and inside the metadata as well.
This will allow for 
programatically adding further data from `Journal.json` (weather, ...) (so be sure
to keep the Journal.json file around) and also creates unique file names.
If you won't be needing any of that and don't want long file names you could probably just shorten the UUID and things will still work fine.

How to use:

Unzip the Day One JSON export into a directory and place the scripts there. You should then have a Journal.json file and directories for the attachments.

When `Journal.json` is the DayOne export, call

`jq -r -f journal.jq < Journal.json | awk -f journal.awk`

which will create one `.md` file per Day One entry in the current directory, prefixed with `YYYY-MM-DDTHH` (year, month, day, hour).
This call is really fast and will only take a few seconds per 10,000 entries.

Then call

`sh ./move.sh`

to create subdirectories from the filename prefixes and to move the files into the YYYY/YYYY-MM folders. This will take a few minutes per 10,000 files,
probably because 99.9% of the calls to `mkdir -p` are actually redundant. No optimization here yet but easy to come up with a script-based solution here.

The 'videos', 'audios', 'photos', 'pdfs' subfolders and their contents stay unchanged. (FYI, Day One uses the MD5 hash for the filenames.)

Changes you can make:
- If you want `MM:SS` to be in the filename, you can add that.
- If you want, edit the `move.sh` script to have all YYYY/YYYY-MM folders one level deeper, say, inside a 'Day One Text' folder,
if you don't like having all the 'YYYY' folders at the top level.
- If you don't want to use the MD5 value for the attachment filenames, and use the original filenames (where available) or the Day One `identifier` field,
you could modify the files here or later create a separate `.jq` and `.awk` script along the approach here to do that.

Obsidian will find all files even if you don't use path names, especially if they are unique like in the current mechanism chosen here.

Plans:
-  Allow for updates: when processing a new exported journal file, check for which UUIDs Markdown files have already been created and only add new entries. (Because in the meantime I have made edits to the MD files and only the newer ones should be ingested.)
    - Work in progress. You can follow the first steps in this direction by looking into 'update.sh' and 'update.awk'.
- Timestamp is currently still UTC. Might want to change this to timezone of the Day One entry (stored in the metadata / front-matter).
- Make the script more robust so that if the EOF separator is used inside text that the process doesn't trip over that.

Thanks to the following work

* [https://github.com/ze-kel/DayOne-JSON-to-MD/blob/main/app.py](https://github.com/ze-kel/DayOne-JSON-to-MD/blob/main/app.py)
* [https://github.com/quantumgardener/dayone-to-obsidian/blob/master/splitfile.py](https://github.com/quantumgardener/dayone-to-obsidian/blob/master/splitfile.py)
* [https://github.com/edoardob90/dayone-to-obsidian/blob/main/utils.py](https://github.com/edoardob90/dayone-to-obsidian/blob/main/utils.py)
* [https://github.com/arnaudlimbourg/dayone-to-obsidian/blob/main/utils.py](https://github.com/arnaudlimbourg/dayone-to-obsidian/blob/main/utils.py)

that I “compared notes” with.
