#!/usr/bin/env python3
"""Run with: python3 tests/test_monitor_workspace_setup.py"""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import time
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'roles/linux-config/.config/hypr/scripts/monitor_workspace_setup.sh'

MOCK = r'''#!/usr/bin/env python3
import json, os, re, sys
from pathlib import Path
p = Path(os.environ['MOCK_STATE'])
s = json.loads(p.read_text())
args = sys.argv[1:]
if args[0] == 'monitors': print(json.dumps([{'name': n} for n in s['monitors']]))
elif args[0] == 'workspacerules': print(json.dumps(s['rules']))
elif args[0] == 'workspaces': print(json.dumps(s['workspaces']))
elif args[0] == 'activeworkspace': print(json.dumps({'id': s['focus']}))
elif args[0] == 'eval':
    ws, monitor = re.search(r'workspace = "(\d+)", monitor = "([^"]+)"', args[1]).groups()
    s['rules'] = [r for r in s['rules'] if r['workspaceString'] != ws]
    s['rules'].append({'workspaceString': ws, 'monitor': monitor, 'enabled': True})
    p.write_text(json.dumps(s)); print('ok')
elif args[0] == 'dispatch':
    if '.move(' in args[1]:
        ws, monitor = re.search(r'workspace = (\d+), monitor = "([^"]+)"', args[1]).groups()
        for w in s['workspaces']:
            if w['id'] == int(ws): w['monitor'] = monitor
        s['focus'] = 2
    else: s['focus'] = int(re.search(r'workspace = (\d+)', args[1]).group(1))
    p.write_text(json.dumps(s)); print('ok')
'''


class WatcherTest(unittest.TestCase):
    def test_hotplug_reload_and_focus(self):
        with tempfile.TemporaryDirectory() as tmp:
            path = Path(tmp)
            state = path / 'state.json'
            state.write_text(json.dumps({'monitors': ['HDMI-A-1', 'DP-2', 'eDP-1'], 'rules': [],
                                         'workspaces': [{'id': 1, 'monitor': 'eDP-1'}], 'focus': 1}))
            mock = path / 'hyprctl'
            mock.write_text(MOCK)
            mock.chmod(0o755)
            env = dict(os.environ, PATH=f'{tmp}:' + os.environ['PATH'], MOCK_STATE=str(state))
            proc = subprocess.Popen(['bash', str(SCRIPT)], env=env, stderr=subprocess.PIPE)
            def wait_for(predicate):
                for _ in range(100):
                    try:
                        data = json.loads(state.read_text())
                        if predicate(data): return data
                    except (json.JSONDecodeError, FileNotFoundError): pass
                    time.sleep(.1)
                self.fail('watcher did not reach expected state')
            def assigned(data, external):
                rules = {r['workspaceString']: r['monitor'] for r in data['rules']}
                return rules == {**{str(i): external for i in range(1, 5)}, '5': 'eDP-1'}
            try:
                data = wait_for(lambda s: assigned(s, 'DP-2') and s['focus'] == 1 and s['workspaces'][0]['monitor'] == 'DP-2')
                data['rules'] = []  # Hyprland clears dynamic rules on reload.
                state.write_text(json.dumps(data))
                data = wait_for(lambda s: assigned(s, 'DP-2'))
                data['monitors'] = ['HDMI-A-1', 'eDP-1']
                state.write_text(json.dumps(data))
                wait_for(lambda s: assigned(s, 'HDMI-A-1') and s['focus'] == 1 and s['workspaces'][0]['monitor'] == 'HDMI-A-1')
            finally:
                proc.terminate()
                proc.wait(timeout=5)
                proc.stderr.close()


if __name__ == '__main__':
    unittest.main()
