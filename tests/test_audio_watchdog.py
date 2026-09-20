import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]


class RecoveryTests(unittest.TestCase):
    def run_watchdog(self, replies, reconnect=False):
        with tempfile.TemporaryDirectory() as temp:
            root = Path(temp)
            shutil.copy(ROOT / 'bin/audio-watchdog', root / 'audio-watchdog')
            stub = root / 'stub'
            stub.write_text('''#!/usr/bin/env python3
import os, pathlib, sys
root=pathlib.Path(os.environ['TEST_ROOT'])
name=pathlib.Path(sys.argv[0]).name
with (root/'calls').open('a') as f: f.write(name+' '+ ' '.join(sys.argv[1:])+'\\n')
if name=='pactl':
 p=root/'replies'; values=p.read_text().split(); p.write_text(' '.join(values[1:])); sys.exit(int(values[0]))
if name=='pidof': sys.exit(1)
if name=='timeout': os.execvp(sys.argv[2],sys.argv[2:])
if name=='bluetoothctl':
 if sys.argv[1]=='info': print('Connected: no')
 else: sys.exit(1)
''')
            stub.chmod(0o755)
            for name in ['pactl', 'pidof', 'timeout', 'systemctl', 'sleep', 'logger', 'bluetoothctl', 'audio-watchdog-snapshot']:
                (root / name).symlink_to(stub)
            (root / 'replies').write_text(' '.join(map(str, replies)))
            env = os.environ.copy()
            env.update(PATH=str(root)+':'+env['PATH'], TEST_ROOT=str(root))
            env.pop('AUDIO_WATCHDOG_BLUETOOTH_DEVICE', None)
            if reconnect:
                env['AUDIO_WATCHDOG_BLUETOOTH_DEVICE'] = '00:11:22:33:44:55'
            result = subprocess.run(['bash', str(root / 'audio-watchdog')], env=env, capture_output=True, timeout=5)
            return result.returncode, (root / 'calls').read_text()

    def test_healthy_does_not_restart(self):
        code, calls = self.run_watchdog([0])
        self.assertEqual(code, 0)
        self.assertNotIn('restart', calls)
        self.assertNotIn('snapshot', calls)

    def test_transient_does_not_restart(self):
        code, calls = self.run_watchdog([124, 0])
        self.assertEqual(code, 0)
        self.assertNotIn('restart', calls)

    def test_recovered_without_bluetooth_is_success(self):
        code, calls = self.run_watchdog([124, 124, 0])
        self.assertEqual(code, 0)
        self.assertLess(calls.index('audio-watchdog-snapshot'), calls.index('systemctl --user restart'))
        self.assertNotIn('bluetoothctl', calls)

    def test_failed_reconnect_does_not_mask_recovery(self):
        code, calls = self.run_watchdog([124, 124, 0], reconnect=True)
        self.assertEqual(code, 0)
        self.assertIn('bluetoothctl connect', calls)

    def test_unrecovered_is_failure(self):
        code, calls = self.run_watchdog([124, 124, 124], reconnect=True)
        self.assertEqual(code, 1)
        self.assertNotIn('bluetoothctl', calls)


if __name__ == '__main__':
    unittest.main()
