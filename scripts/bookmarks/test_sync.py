"""Run with: python3 -m unittest discover -s scripts/bookmarks -v"""
import importlib.util
import json
import plistlib
from pathlib import Path
import sqlite3
import subprocess
import sys
import tempfile
import unittest

SCRIPT = Path(__file__).with_name('sync.py')
spec = importlib.util.spec_from_file_location('bookmark_sync', SCRIPT)
sync = importlib.util.module_from_spec(spec)
spec.loader.exec_module(sync)


def bookmark(title='Example', url='https://example.com/?a=1&b=2'):
    return {'id': 'one', 'title': title, 'url': url}


class SyncTests(unittest.TestCase):
    def test_html_roundtrip_and_invalid_input(self):
        doc = sync.document([{'id': 'folder', 'title': 'Work <tools>', 'children': [bookmark()]}, {'id': 'empty', 'title': 'Empty', 'children': []}])
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'bookmarks.html'
            path.write_text(sync.render_html(doc))
            self.assertEqual(sync.read_html(path), doc)
            path.write_text('<html>Not bookmarks</html>')
            with self.assertRaises(ValueError):
                sync.read_html(path)

    def test_conflicts_and_deletion(self):
        base = sync.document([bookmark()])
        empty = sync.document([])
        changed = sync.document([bookmark('Changed')])
        self.assertEqual(sync.merge(base, [base, empty]), empty)
        self.assertEqual(sync.merge(base, [changed, changed]), changed)
        with self.assertRaises(ValueError):
            sync.merge(base, [empty, changed])
        self.assertEqual(sync.additions(base['children'], [bookmark()]), base['children'])
        with self.assertRaises(ValueError):
            sync.document([bookmark(), bookmark()])

    def test_firefox_read_only(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'places.sqlite'
            with sqlite3.connect(path) as db:
                db.executescript('CREATE TABLE moz_bookmarks(id,parent,type,title,fk,position); CREATE TABLE moz_places(id,url); INSERT INTO moz_places VALUES(1,"https://example.com"); INSERT INTO moz_bookmarks VALUES(2,1,2,"Toolbar",NULL,0); INSERT INTO moz_bookmarks VALUES(3,2,1,"Example",1,0);')
            before = path.read_bytes()
            doc = sync.read_native(path, 'firefox')
            self.assertEqual(doc['children'][0]['children'][0]['url'], 'https://example.com')
            self.assertEqual(path.read_bytes(), before)

    def test_chromium_and_safari_import(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp) / 'Bookmarks'
            path.write_text(json.dumps({'roots': {'bookmark_bar': {
                'type': 'folder', 'name': 'Toolbar', 'children': [
                    {'type': 'url', 'name': 'Example', 'url': 'https://example.com'}
                ]}}}))
            doc = sync.read_native(path, 'chromium')
            self.assertEqual(doc['children'][0]['children'][0]['title'], 'Example')
            path.write_bytes(plistlib.dumps({
                'WebBookmarkType': 'WebBookmarkTypeList', 'Children': [{
                    'WebBookmarkType': 'WebBookmarkTypeLeaf',
                    'URLString': 'https://example.com',
                    'URIDictionary': {'title': 'Example'},
                }]}))
            self.assertEqual(sync.read_native(path, 'safari')['children'][0]['title'], 'Example')

    def test_cli_sync_lifecycle(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / 'source'
            source.mkdir()
            state = root / 'state'
            canonical = source / 'work.json'
            canonical.write_text(sync.encoded(sync.document([bookmark()])))
            endpoint = root / 'work.html'
            other = root / 'other.html'

            def run(*args, success=True):
                result = subprocess.run([sys.executable, str(SCRIPT), '--source', str(source), '--state', str(state), *args], capture_output=True, text=True)
                self.assertEqual(result.returncode, 0 if success else 1, result.stderr)
                return result

            run('export', '--profile', 'work', '--file', str(endpoint))
            run('export', '--profile', 'work', '--file', str(other))
            command = ['sync', '--profile', 'work', '--endpoint', str(endpoint), '--endpoint', str(other)]
            run(*command)
            endpoint.write_text(sync.render_html(sync.document([bookmark('Updated')])) )
            run(*command)
            self.assertEqual(json.loads(canonical.read_text())['children'][0]['title'], 'Updated')
            self.assertEqual(sync.read_html(other), json.loads(canonical.read_text()))
            before = canonical.read_bytes()
            run(*command)
            self.assertEqual(before, canonical.read_bytes())
            endpoint.write_text(sync.render_html(sync.document([])))
            canonical.write_text(sync.encoded(sync.document([bookmark('Conflicting')])))
            before = canonical.read_bytes()
            run(*command, success=False)
            self.assertEqual(before, canonical.read_bytes())
            other.unlink()
            run(*command, success=False)
            self.assertEqual(before, canonical.read_bytes())
            self.assertTrue(list((state / 'backups').iterdir()))


if __name__ == '__main__':
    unittest.main()
