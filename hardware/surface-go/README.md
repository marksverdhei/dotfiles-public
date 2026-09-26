# Surface Go 2 power-button suspend (experimental)

Opt-in setup for Omarchy on the Surface Go 2. Nothing in the normal bootstrap
installs this profile. A short power-button press requests suspend instead of
opening the power menu. Resume does not automatically require a password; manual
locking remains available. There are no idle timers in this profile, and the
installer does not change lid handling.

## Why the keyboard hook exists

On the tested Surface Go 2 with kernel `7.1.9-arch1-2`, suspend with the Microsoft
Type Cover `045e:09b5` attached failed with `usbhid ... suspend error -5` on its
keyboard and touchpad interfaces. The hook releases this cover's `usbhid`
interfaces before suspend and restores the recorded interfaces after resume or a
failed sleep attempt. Other USB devices are left alone. This is a workaround,
not a confirmed kernel fix. The cover can stay physically attached, but it cannot
provide keyboard/touchpad wake while its driver is disconnected; use the tablet's
power button. Both tablet button wake sources were enabled on the tested machine.

## Setup

Run from this repository on the Surface, as the desktop user:

```bash
sudo bash hardware/surface-go/install.sh
mkdir -p ~/.config/hypr/surface-go
cp hardware/surface-go/bindings.conf ~/.config/hypr/surface-go/bindings.conf
```

The installer checks the model, saves any previous hook and the sleep target
states in the printed `/var/lib/surface-go-suspend-backup.*` directory, installs
the hook, and unmasks only `sleep.target` and `suspend.target`. Keep that backup
path for rollback. No reboot is required.

Add this line once, at the end of the local `~/.config/hypr/hyprland.conf` (or a
host-only file sourced after default bindings):

```ini
source = ~/.config/hypr/surface-go/bindings.conf
```

If this host already has the earlier direct `XF86PowerOff` override in
`bindings.conf`, remove that override when enabling this source. Avoid committing
the source line to a config shared with other hosts.

Install the no-lock idle profile. Moving the old file preserves a dotfiles
symlink rather than editing its shared target. Run this backup step only once;
it deliberately refuses to overwrite an existing backup:

```bash
if [ -e ~/.config/hypr/hypridle.conf.before-surface-go ] ||
   [ -L ~/.config/hypr/hypridle.conf.before-surface-go ]; then
    echo 'Backup already exists; stop and inspect it before continuing.'
else
    mv ~/.config/hypr/hypridle.conf ~/.config/hypr/hypridle.conf.before-surface-go &&
    cp hardware/surface-go/hypridle.conf ~/.config/hypr/hypridle.conf
fi
hyprctl reload
hyprctl configerrors
omarchy restart hypridle
```

The earlier local implementation also edited shared `hypr/hypridle.conf`. This
PR leaves shared defaults unchanged; adopting this profile does not undo those
pre-existing local edits.

## Validation before marking the PR ready

Already checked on the original machine: Hyprland accepted the power binding
and idle settings; logind reported suspend available; a manual pre/post hook
cycle released and restored all four cover interfaces and recreated keyboard
and touchpad input devices. This does **not** verify actual suspend/resume.

With the cover attached, test at least two cycles:

1. Tap power, then wait for the machine to finish entering sleep.
2. Tap power once and confirm the desktop returns without automatic locking.
3. Confirm keyboard and touchpad work, and the machine does not immediately
   suspend again. Repeat on battery and AC when practical.
4. Inspect `journalctl -b -u systemd-suspend.service` and
   `journalctl -b -k` for successful suspend/resume and absence of the USB errors.

Do not switch sleep modes as part of this setup: the original host uses `s2idle`.
See the [Surface Go 2 notes](https://github.com/linux-surface/linux-surface/wiki/Surface-Go-2)
and [systemd sleep hook documentation](https://www.freedesktop.org/software/systemd/man/latest/systemd-suspend.service.html).

## Rollback

Remove the added `source` line, restore `hypridle.conf.before-surface-go` to
`hypridle.conf`, then run `hyprctl reload`, `hyprctl configerrors`, and
`omarchy restart hypridle`. Restore the previous hook from the installer's printed
backup directory, or remove `/usr/lib/systemd/system-sleep/surface-go-type-cover`
if no previous hook existed. Perform rollback while awake, after the hook's
post step has finished.

Consult `units-before.txt` in that backup. Only if both targets were previously
masked, restore that state with:

```bash
sudo systemctl mask sleep.target suspend.target
```

If only one was masked, mask only that target. A prior runtime mask should be
restored using `systemctl mask --runtime` instead. Keep the backups until rollback
is verified. No hibernate settings or lid/idle policies need restoring.
