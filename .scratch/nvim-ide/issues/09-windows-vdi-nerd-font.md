Type: task
Status: open

## Question

Nothing to decide here: ticket 07 found that the Linux box (reached over SSH) needs a Nerd Font active wherever glyphs actually render — which is client-side, on the Windows VDI running PowerShell as the SSH client, not the Linux box itself. The current VDI is Windows 10 without Windows Terminal, and is about to be replaced by a newly-provisioned Windows 11 VDI, so configuring it now would be wasted work. Deferred until that VDI exists.

Once the Windows 11 VDI is provisioned:
- Confirm which terminal app is hosting the PowerShell SSH session (Windows Terminal should be available by default on Windows 11, unlike the Windows 10 VDI).
- Install a Nerd Font on that VDI — check first whether file transfer/font installation is restricted by policy; per-user install (no admin) is usually possible on modern Windows via right-click → "Install for me only" on the `.ttf`.
- Point the terminal's font setting at it (Windows Terminal: Settings → the PowerShell profile → Appearance → Font face, or edit `settings.json`'s `font.face`).
- Confirm glyph rendering, same way ticket 04 and ticket 07 confirmed it elsewhere.

This is a HITL task — provisioning timing and VDI policy are outside this session's control.

## Answer

(record what was installed/configured and the glyph-rendering confirmation here when done)
