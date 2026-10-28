# Bookmarks

`default.json` and `work.json` are independent versioned collections.
The files start empty; installation does not change any browser bookmarks.
`bookmark-sync` uses Python 3 and the standard library on macOS/Linux.

## Install and import

From the repository:

```sh
./install.sh links config bin
bookmark-sync --help
bookmark-sync discover
```

Before linking, the command can also run directly:

```sh
python3 scripts/bookmarks/sync.py --help
```

The wrapper uses `~/dotfiles`; set `DOTFILES_DIR` for a different checkout.
Discovery prints candidate native stores without opening them. Verify Helium's
actual profile path in `chrome://version`, and Firefox's in `about:profiles`.
Safari may require macOS permission to read its bookmark file; HTML export is
an alternative. The command never changes macOS permissions.

Import an HTML export from a browser:

```sh
bookmark-sync import --profile work --file ~/Downloads/work-bookmarks.html
```

Or import directly from a native store (read-only):

```sh
bookmark-sync import --profile work --format chromium --file '/actual/Helium/Profile 1/Bookmarks'
bookmark-sync import --profile default --format firefox --file '/actual/Firefox/profile/places.sqlite'
bookmark-sync import --profile default --format safari --file ~/Library/Safari/Bookmarks.plist
```

Importing a native store imports its entire bookmark tree. Safari's tree is
shared across profiles, so prefer separate HTML exports for separate
collections, or organize the imported tree before exporting it again.
Import only adds: existing IDs survive, folders with matching titles merge,
and bookmarks matching title and exact URL in the same folder are skipped.
Native import includes toolbar/menu folders but omits browser-only metadata,
Firefox separators and Safari reading-list proxy entries. Firefox tag
semantics are not preserved. It does not
track native edits or deletions. Reimporting a renamed bookmark adds a new entry.

Review `git diff` before committing. These collections can contain internal
work URLs; choose what belongs in this repository when importing.

## Edit, diff, and sync

Each entry has a unique string `id`, a `title`, and either a `url` or an ordered
`children` array. Keep IDs stable when editing. Empty folders are supported.

Export a collection to an HTML interchange file outside the repository:

```sh
bookmark-sync export --profile work --file ~/Downloads/work.html
bookmark-sync diff --profile work --endpoint ~/Downloads/work.html
bookmark-sync sync --profile work --endpoint ~/Downloads/work.html
```

The first sync requires every endpoint to equal the collection, then saves a
baseline. For an existing HTML file, import its additions and export the merged
source back to that file before the first sync. Multiple endpoints are supported
by repeating `--endpoint`; changing the endpoint set requires bootstrapping again.

Subsequent syncs compare the source and endpoints to that baseline. One changed
version propagates to all endpoints, including deletions. Different simultaneous
changes stop with a conflict before writing anything. This first version treats
the whole tree as one merge unit, so even independent simultaneous edits require
manual reconciliation. The `diff` command shows source-versus-endpoint changes.
Use it to edit the files to agree, or import additions and re-export the source
when that is the intended resolution. Import does not resolve deletions.

Generated HTML includes `DATA-DOTFILES-ID` attributes for stable identity. Browsers
may discard these attributes when importing/exporting. A fresh browser export
must go through `import`, then `export`, rather than replacing an established
sync endpoint. That workflow preserves existing matching source IDs.

**HTML endpoint sync does not update a running browser.** Import the generated
HTML using the browser's UI. Browser imports may append folders or duplicate
entries; remove the previous managed folder manually when replacing it.
Do not point this command at browser-owned native files for writing.

Safari makes all bookmarks visible in all profiles. Select each collection's
folder as the corresponding Safari profile's Favorites folder; this separates
the Favorites bars, not access to the underlying bookmarks.

## State and recovery

Baselines, a process lock, and pre-write backups live under
`${XDG_STATE_HOME:-~/.local/state}/bookmark-sync/`. They are machine-local.
The command prints backup paths and their original destinations. Restore the
chosen backup manually, then inspect `diff` before syncing again. Source JSON
can also be restored through Git. Do not delete state to resolve a conflict.

Writes use temporary files and atomic replacement per file. A batch is not one
filesystem transaction: if a disk error interrupts it, restore backups or retry
after reviewing the files. The baseline advances only after all writes succeed.
Missing or invalid endpoints abort sync rather than deleting bookmarks.

Global `--source` and `--state` options go before the command. For example:

```sh
python3 scripts/bookmarks/sync.py --source /tmp/bookmark-source --state /tmp/bookmark-state diff --profile work --endpoint /tmp/work.html
python3 -m unittest discover -s scripts/bookmarks -v
```

## Remaining browser automation

The shared-source/interchange core is implemented. Next steps are a local profile
mapping config, a closed-browser Chromium writer that preserves native metadata,
and a Firefox extension/native messaging adapter using the bookmarks API.
Safari remains on documented HTML interchange until a reliable automation adapter
is verified. Do not schedule native-store writes or symlink browser data files.
No background agent, automatic Git commits, or browser-native writes are installed.

References:

- [Safari profiles and shared bookmarks](https://support.apple.com/en-ie/105100)
- [Safari HTML interchange](https://developer.apple.com/documentation/SafariServices/importing-data-exported-from-safari)
- [Firefox profile storage](https://support.mozilla.org/en-US/kb/profiles-where-firefox-stores-user-data)
- [Firefox bookmark API](https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/Work_with_the_Bookmarks_API)
