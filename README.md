# Update Obsidian vault from Day One (“DayOne”) JSON using command line scripts

NEW: The scripts now also update the Obsidian vault with new Day One entries (those with new UUIDs).

NOTE: Please only use these scripts if you have a grasp of what they do and they either do exactly what you need or you can edit them to your taste.

The Markdown files are named in the form `YYYY-MM-DDTHH-<Day One UUID>`.
A "title" inside the file is not used for the filename but can easily be added.
The files will be moved into `Day One Export/YYYY/YYYY-MM` directories which are created as needed.
All known Day One attachment types are supported. The script creates Wiki-style links of the form `[[Link]]`. Obsidian will find the files.

The scripts need `awk` and `sed` (the usual suspects for text processing), `make`, all of which a Linux or Mac system will have if set up for development, and you will probably need to install `jq` (e. g. with `sudo apt install jq`) for reading and filtering JSON. If you develop on Windows you know how to get all this there, too.

Here a description of the chosen approach, where each script does one thing, and each file is easy to read and understand and change:
- The `update.awk` script uses some interim files created by two preceding calls (one with the UUIDs from the export file, the other with the UUIDs already in the file system) and creates a `.jq`script which then only has the new UUIDs for further processing.
- The `journal.jq` script flattens the JSON file and creates a long Markdown file divided into segments for further processing. 
  Some segments will not appear in the final output but are solely for the following stages. Tags are processed and a meaningful set of Day One metadata is stored, but Obsidian will actually only make use of the tags.
- The `journal.awk` script reads this file, uses the special data segments and the metadata for its own logic (creating filenames, replacing Day One links to attachments to Obsidian links, …), and creates one file per Day One entry.
- The `move.sh` script looks at the outputted `.md` files and creates folders of the form `YYYY/YYYY-MM` as needed and moves the files.
- An `.sed` script is used to fix some character escaping that Day One does.

The `.md` files have metadata ("Front-matter" in Obsidian). The Day One UUID is in the filename and inside the metadata as well.
This will allow for later
programatically adding further data from `Journal.json` (weather, ...; so be sure
to keep the `Journal.json` file around) and also creates unique file names.
If you won't be needing any of that and don't want long file names you could probably just shorten the UUID and things will still work fine.

How to use:

1. Clone the project into a directory parallel to your Obsidian vault directory. (Both assumed to be in your home directory "~".)
2. Inside the vault directory create a soft link to the makefile:

        ln -s ~/dayone-json-to-obsidian/makefile makefile
    
3. Download the Day One JSON export ZIP file into the vault directory.
4. Now depending on if this is the first time or an update, from inside your vault directory:
    1. Call `make initial`, if this is the first time around.
    2. Just call `make`, if this is an update, and remember, the zip file does not have to contain the whole history, just the latest entries with some overlap to be safe. Only entries with new  UUIDs will be imported.

The ZIP file will be deleted so you can repeat these steps every time you do a new export.

Creating the markdown files is really fast and will only take a few seconds per 10,000 entries.

Moving the files will take a few minutes per 10,000 files,
probably because 99.9% of the calls to `mkdir -p` are actually redundant. No optimization here yet but easy to come up with a script-based solution here.

The 'videos', 'audios', 'photos', 'pdfs' subfolders and their contents stay unchanged. (FYI, Day One uses the MD5 hash for the filenames.)

Changes you can make:
- The YYYY directories will be inside a “Day One Export” directory. Replace this value inside `move.sh` by a name of your choosing or by `.` if you want everything at the top level.
- If you want `MM:SS` to be in the filename, you can add that.
- If you don't want to use the MD5 value for the attachment filenames, and instead want to use the original filenames (where available) or the Day One `identifier` field,
you could modify the files here or later create a separate `.jq` and `.awk` script along the approach here to do that.

Obsidian will find all files even if you don't use path names, especially if they are unique like in the current mechanism chosen here.

Plans:
- Timestamp is currently still UTC. Might want to change this to timezone of the Day One entry (stored in the metadata / front-matter).
- Make the script more robust so that if the EOF separator is used inside text that the process doesn't trip over that.

Thanks to the following work

* [https://github.com/ze-kel/DayOne-JSON-to-MD/blob/main/app.py](https://github.com/ze-kel/DayOne-JSON-to-MD/blob/main/app.py)
* [https://github.com/quantumgardener/dayone-to-obsidian/blob/master/splitfile.py](https://github.com/quantumgardener/dayone-to-obsidian/blob/master/splitfile.py)
* [https://github.com/edoardob90/dayone-to-obsidian/blob/main/utils.py](https://github.com/edoardob90/dayone-to-obsidian/blob/main/utils.py)
* [https://github.com/arnaudlimbourg/dayone-to-obsidian/blob/main/utils.py](https://github.com/arnaudlimbourg/dayone-to-obsidian/blob/main/utils.py)

that I “compared notes” with (but decided on a different, Linux-style approach, and added the update feature).
