#!/usr/bin/env python3
"""Versioned bookmark collections and safe HTML interchange. Python stdlib only."""
import argparse
import configparser
import difflib
import fcntl
import hashlib
import html
from html.parser import HTMLParser
import json
import os
from pathlib import Path
import plistlib
import shutil
import sqlite3
import sys
import tempfile
import uuid

PROFILES = ('default', 'work')
REPO = Path(__file__).resolve().parents[2]


def document(children):
    result = {'version': 1, 'children': children}
    validate(result)
    return result


def validate(doc):
    if doc.get('version') != 1 or not isinstance(doc.get('children'), list):
        raise ValueError('Expected version 1 and a children array')
    seen = set()

    def walk(nodes):
        for node in nodes:
            if not isinstance(node.get('id'), str) or not node['id'] or node['id'] in seen:
                raise ValueError('Each bookmark/folder needs a unique nonempty string ID')
            seen.add(node['id'])
            if not isinstance(node.get('title'), str):
                raise ValueError('Each entry needs a string title')
            if ('url' in node) == ('children' in node):
                raise ValueError('Each entry needs either url or children')
            if 'children' in node:
                if not isinstance(node['children'], list):
                    raise ValueError('Folder children must be an array')
                walk(node['children'])
            elif not isinstance(node['url'], str) or not node['url']:
                raise ValueError('Bookmark URL must be a nonempty string')
    walk(doc['children'])
    return doc


def encoded(doc):
    return json.dumps(doc, indent=2, ensure_ascii=False) + '\n'


class BookmarksHTML(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.root = []
        self.stack = [self.root]
        self.pending = None
        self.entry = None
        self.tag = None
        self.dls = 0
        self.recognized = False

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if tag in ('a', 'h3'):
            self.tag = tag
            self.entry = {'id': attrs.get('data-dotfiles-id') or str(uuid.uuid4()), 'title': ''}
            if tag == 'a':
                self.entry['url'] = attrs.get('href', '')
            else:
                self.entry['children'] = []
        elif tag == 'dl':
            self.recognized = True
            self.dls += 1
            if self.pending is not None:
                self.stack.append(self.pending)
                self.pending = None
            elif self.dls > 1:
                raise ValueError('Unexpected nested bookmark list')

    def handle_data(self, data):
        if self.entry is not None:
            self.entry['title'] += data

    def handle_endtag(self, tag):
        if tag == self.tag and self.entry is not None:
            self.stack[-1].append(self.entry)
            self.pending = self.entry.get('children')
            self.entry = None
            self.tag = None
        elif tag == 'dl':
            self.dls -= 1
            if len(self.stack) > 1:
                self.stack.pop()


def read_html(path):
    parser = BookmarksHTML()
    parser.feed(path.read_text(encoding='utf-8-sig'))
    parser.close()
    if not parser.recognized or parser.dls != 0 or parser.entry is not None:
        raise ValueError('Not a complete Netscape bookmark HTML file')
    return document(parser.root)


def render_html(doc):
    lines = ['<!DOCTYPE NETSCAPE-Bookmark-file-1>', '<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=UTF-8">', '<TITLE>Bookmarks</TITLE>', '<H1>Bookmarks</H1>']

    def walk(nodes, depth):
        pad = '    ' * depth
        lines.append(pad + '<DL><p>')
        for node in nodes:
            attr = ' DATA-DOTFILES-ID="' + html.escape(node['id'], quote=True) + '"'
            title = html.escape(node['title'])
            if 'url' in node:
                lines.append(pad + '    <DT><A HREF="' + html.escape(node['url'], quote=True) + '"' + attr + '>' + title + '</A>')
            else:
                lines.append(pad + '    <DT><H3' + attr + '>' + title + '</H3>')
                walk(node['children'], depth + 1)
        lines.append(pad + '</DL><p>')
    walk(doc['children'], 0)
    return '\n'.join(lines) + '\n'


def read_native(path, fmt):
    # Native files are import-only. Never write browser-owned databases/plists.
    if fmt == 'chromium':
        raw = json.loads(path.read_text())

        def convert(node):
            item = {'id': str(uuid.uuid4()), 'title': node.get('name', '')}
            if node.get('type') == 'url':
                item['url'] = node['url']
            else:
                item['children'] = [convert(n) for n in node.get('children', [])]
            return item
        return document([convert(n) for n in raw['roots'].values() if isinstance(n, dict) and n.get('type') == 'folder'])
    if fmt == 'safari':
        raw = plistlib.loads(path.read_bytes())

        def convert(node):
            if node.get('WebBookmarkType') == 'WebBookmarkTypeList':
                return {'id': str(uuid.uuid4()), 'title': node.get('Title', ''), 'children': [convert(n) for n in node.get('Children', []) if n.get('WebBookmarkType') in ('WebBookmarkTypeLeaf', 'WebBookmarkTypeList')]}
            return {'id': str(uuid.uuid4()), 'title': node.get('URIDictionary', {}).get('title', node.get('URLString', '')), 'url': node['URLString']}
        return document(convert(raw)['children'])
    if fmt == 'firefox':
        # SQLite backup includes committed WAL contents without copying live files.
        source = sqlite3.connect(path.resolve().as_uri() + '?mode=ro', uri=True, timeout=5)
        copy = sqlite3.connect(':memory:')
        try:
            source.backup(copy)
            rows = copy.execute('SELECT b.id,b.parent,b.type,b.title,p.url FROM moz_bookmarks b LEFT JOIN moz_places p ON p.id=b.fk ORDER BY b.position').fetchall()
            def children(parent):
                out = []
                for ident, ancestor, kind, title, url in rows:
                    if ancestor != parent or kind not in (1, 2):
                        continue
                    node = {'id': str(uuid.uuid4()), 'title': title or ''}
                    if kind == 1:
                        node['url'] = url
                    else:
                        node['children'] = children(ident)
                    out.append(node)
                return out
            return document(children(1))
        finally:
            copy.close()
            source.close()
    return read_html(path)


def additions(existing, incoming):
    """Import adds entries; matching titles/folders or title+URL retain source IDs."""
    result = json.loads(json.dumps(existing))
    for node in incoming:
        match = next((n for n in result if n['title'] == node['title'] and n.get('url') == node.get('url')), None)
        if match is None:
            result.append(node)
        elif 'children' in node:
            match['children'] = additions(match['children'], node['children'])
    return result


def merge(base, variants):
    # ponytail: whole-tree conflicts; field-level merging can follow real demand.
    changed = []
    for variant in variants:
        if variant != base and variant not in changed:
            changed.append(variant)
    if len(changed) > 1:
        raise ValueError('Conflict: multiple different edits since last sync; reconcile using diff/import first')
    return changed[0] if changed else base


def save(path, content, state):
    path = path.expanduser().resolve()
    if path.exists() and path.read_text() == content:
        return
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        backups = state / 'backups'
        backups.mkdir(parents=True, exist_ok=True)
        backup = backups / (uuid.uuid4().hex + '-' + path.name)
        shutil.copy2(path, backup)
        print(f'Backup: {backup} (restore to {path})')
    fd, temporary = tempfile.mkstemp(dir=path.parent, prefix='.bookmark-sync-')
    try:
        with os.fdopen(fd, 'w') as stream:
            stream.write(content)
            stream.flush()
            os.fsync(stream.fileno())
        os.replace(temporary, path)
    finally:
        if os.path.exists(temporary):
            os.unlink(temporary)


def discover():
    home = Path.home()
    for root in [home / 'Library/Application Support/net.imput.helium', home / 'Library/Application Support/Helium', home / '.config/helium']:
        for path in sorted(root.glob('*/Bookmarks')):
            print(f'chromium\t{path}')
    for root in [home / 'Library/Application Support/Firefox', home / '.mozilla/firefox']:
        ini = configparser.ConfigParser()
        ini.read(root / 'profiles.ini')
        for section in ini.sections():
            if ini.has_option(section, 'Path'):
                path = Path(ini[section]['Path'])
                if ini[section].get('IsRelative', '1') == '1':
                    path = root / path
                print(f'firefox\t{ini[section].get("Name", section)}\t{path / "places.sqlite"}')
    safari = home / 'Library/Safari/Bookmarks.plist'
    if safari.exists():
        print(f'safari\t(shared across profiles)\t{safari}')
    print('Verify Helium profile paths in chrome://version; discovery is best-effort.')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--source', type=Path, default=REPO / 'roles/config/.config/bookmarks')
    parser.add_argument('--state', type=Path, default=Path(os.environ.get('XDG_STATE_HOME', str(Path.home() / '.local/state'))) / 'bookmark-sync')
    sub = parser.add_subparsers(dest='command', required=True)
    sub.add_parser('discover')
    for name in ('import', 'export', 'diff', 'sync'):
        cmd = sub.add_parser(name)
        cmd.add_argument('--profile', choices=PROFILES, required=True)
        if name in ('import', 'export'):
            cmd.add_argument('--file', type=Path, required=True)
        if name == 'import':
            cmd.add_argument('--format', choices=('html', 'chromium', 'firefox', 'safari'), default='html')
        if name in ('diff', 'sync'):
            cmd.add_argument('--endpoint', type=Path, action='append', required=True, help='Existing HTML interchange file; repeat for more endpoints')
    args = parser.parse_args()
    if args.command == 'discover':
        discover()
        return
    args.state = args.state.expanduser()
    args.state.mkdir(parents=True, exist_ok=True)
    with (args.state / 'lock').open('a') as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        path = args.source.expanduser() / (args.profile + '.json')
        doc = validate(json.loads(path.read_text()))
        if args.command == 'import':
            incoming = read_native(args.file.expanduser(), args.format)
            result = document(additions(doc['children'], incoming['children']))
            save(path, encoded(result), args.state)
            print('Imported additions; existing entries and deletions preserved.')
        elif args.command == 'export':
            if args.file.suffix.lower() not in ('.html', '.htm'):
                raise ValueError('Export destination must be an HTML file')
            save(args.file, render_html(doc), args.state)
        else:
            endpoints = sorted({p.expanduser().resolve() for p in args.endpoint})
            for endpoint in endpoints:
                if endpoint.suffix.lower() not in ('.html', '.htm'):
                    raise ValueError('Sync endpoints must be HTML interchange files')
            variants = [read_html(p) for p in endpoints]
            for endpoint, variant in zip(endpoints, variants):
                delta = ''.join(difflib.unified_diff(encoded(doc).splitlines(True), encoded(variant).splitlines(True), fromfile=str(path), tofile=str(endpoint)))
                print(delta or f'{endpoint}: unchanged', end='\n')
            if args.command == 'diff':
                return
            key = hashlib.sha256(str(path.resolve()).encode()).hexdigest()
            snapshot = args.state / (key + '.json')
            saved = json.loads(snapshot.read_text()) if snapshot.exists() else None
            names = [str(p) for p in endpoints]
            if saved is None or saved['endpoints'] != names:
                if any(v != doc for v in variants):
                    raise ValueError('New endpoint set: import additions, then export the source to each endpoint before first sync')
                result = doc
            else:
                result = merge(validate(saved['document']), [doc] + variants)
            # All inputs and conflicts checked before writing; baseline advances last.
            save(path, encoded(result), args.state)
            for endpoint in endpoints:
                save(endpoint, render_html(result), args.state)
            save(snapshot, encoded({'endpoints': names, 'document': result}), args.state)
            print('Synced. Browser import is a separate manual step.')


if __name__ == '__main__':
    try:
        main()
    except (ValueError, OSError, KeyError, sqlite3.Error, configparser.Error) as error:
        print(f'bookmark-sync: {error}', file=sys.stderr)
        sys.exit(1)
