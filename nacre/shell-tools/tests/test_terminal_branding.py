"""Refresh terminal graphics on palette publication without restarting workers."""

import base64
import fcntl
import importlib.util
import os
from pathlib import Path
import pty
import select
import signal
import struct
import subprocess
import sys
import tempfile
import time
import unittest
from unittest.mock import patch

ROOT = Path(__file__).resolve().parents[3]
spec = importlib.util.spec_from_file_location(
    "branding", ROOT / "nacre/shell-tools/branding.py"
)
branding = importlib.util.module_from_spec(spec)
spec.loader.exec_module(branding)


class TerminalBrandingTests(unittest.TestCase):
    def test_notification_targets_only_exact_menu_controller(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder) / "home"
            proc = Path(folder) / "proc"
            proc.mkdir()
            menu = str(home / ".local/bin/siverteh-ai")
            for pid, argv in [
                (111, ["python3", menu, "dashboard"]),
                (222, ["kitty", menu, "dashboard"]),
                (333, ["python3", menu, "new"]),
                (444, ["python3", "/other/siverteh-ai", "dashboard"]),
            ]:
                path = proc / str(pid)
                path.mkdir()
                (path / "cmdline").write_bytes(b"\0".join(a.encode() for a in argv))
            with (
                patch.object(branding.os, "pidfd_open", return_value=7) as opened,
                patch.object(branding.signal, "pidfd_send_signal") as notified,
                patch.object(branding.os, "close") as closed,
            ):
                branding.refresh_terminal_menus(home, proc)
            opened.assert_called_once_with(111)
            notified.assert_called_once_with(7, signal.SIGWINCH)
            closed.assert_called_once_with(7)

    def test_real_idle_curses_menu_reloads_png_after_redraw_signal(self):
        with tempfile.TemporaryDirectory() as folder:
            home = Path(folder)
            logo = home / ".local/share/nacre/branding/sh.png"
            logo.parent.mkdir(parents=True)
            # The PTY captures Kitty's graphics packets; no terminal decoder or
            # authentication/session state is used in this isolated test.
            first, second = b"first-image", b"updated-image"
            logo.write_bytes(first)
            code = """
import importlib.machinery,importlib.util,os,sys
from pathlib import Path
loader=importlib.machinery.SourceFileLoader('menu',sys.argv[1])
spec=importlib.util.spec_from_loader(loader.name,loader)
menu=importlib.util.module_from_spec(spec);loader.exec_module(menu)
menu.Path.home=lambda:Path(sys.argv[2])
original=menu.curses.wrapper
def wrapper(callback):
 def graphical(screen):
  os.environ['TERM']='xterm-kitty'
  return callback(screen)
 return original(graphical)
menu.curses.wrapper=wrapper
menu.select(['First','Second'],'Workspace')
"""
            master, slave = pty.openpty()
            fcntl.ioctl(
                slave,
                __import__("termios").TIOCSWINSZ,
                struct.pack("HHHH", 30, 90, 0, 0),
            )
            process = subprocess.Popen(
                [sys.executable, "-c", code, str(ROOT / "bin/siverteh-ai"), str(home)],
                stdin=slave,
                stdout=slave,
                stderr=slave,
                env=dict(os.environ, TERM="xterm-256color", TMUX=""),
            )
            os.close(slave)
            output = bytearray()

            def wait_for(packet):
                until = time.monotonic() + 3
                while time.monotonic() < until:
                    ready, _, _ = select.select([master], [], [], 0.1)
                    if ready:
                        try:
                            output.extend(os.read(master, 65536))
                        except OSError:
                            break
                    if packet in output:
                        return True
                return False

            try:
                self.assertTrue(
                    wait_for(base64.b64encode(first)), output.decode(errors="replace")
                )
                logo.write_bytes(second)
                started = time.monotonic()
                os.kill(process.pid, signal.SIGWINCH)
                self.assertTrue(
                    wait_for(base64.b64encode(second)),
                    "Idle menu did not send updated image",
                )
                self.assertLess(time.monotonic() - started, 2)
                # Only this final exit sends keyboard input; recoloring did not.
                os.write(master, b"\x1b")
                process.wait(timeout=3)
                self.assertEqual(process.returncode, 0)
            finally:
                if process.poll() is None:
                    process.terminate()
                    process.wait(timeout=3)
                os.close(master)
