# PatchToolsBags 0.1.5 — 2026-11-06

- Keep confirmed Pawn upgrade arrows visible while their ratings are refreshed, reducing flicker when items enter the inventory.
- Optionally move matching items into specialty and reagent bags when sorting outside combat. Enabled by default; combat sorting still changes the display only.
- Start with bank expansion slots collapsed on both clients and align them with the inventory grid.
- Label the next bank-slot price beside the expansion controls.

Validation: automated checks cover upgrade-cache refresh, specialty-bag routing, bank layout and existing item interactions on both supported clients. Broader gameplay testing remains welcome.

# PatchToolsBags 0.1.4 — 2026-11-05

- Fix the blocked first bank-tab setup on Forever while preserving Blizzard's secure opening flow.
- Show Forever bank expansion slots and forward locked-slot clicks to Blizzard's purchase confirmation.
- Refresh the bank when additional slots become available.
- Prevent Blizzard's carried-bag windows from briefly flashing before the PatchToolsBags window appears.
- Preserve Classic Era support and restore native bag visibility when replacement is disabled.

Validation: Forever bank opening, deposits and withdrawals were confirmed in game. Automated checks cover secure opening, expansion controls and confirmation forwarding, native visibility restoration, sorting and existing item interactions. The final expansion controls and flash correction still need broader gameplay coverage.

# PatchToolsBags 0.1.3 — 2026-11-05

- Fix opening the bag window on Forever.
- Restore item icons and stack counts with the correct Forever item-button type.
- Fix the money display and keep bank-slot prices compatible with the current currency API.
- Preserve Classic Era support and the existing native item interactions.

Validation: bag opening confirmed in game on Forever. Automated checks cover missing legacy mouse/currency functions, item rendering, stack counts, profession bags, dragging and the existing inventory/bank regressions.

# PatchToolsBags 0.1.2 — 2026-10-27

The tested bag and bank improvements are now part of the regular release.

- A compact bank window with search, sorting and separate specialty-bag sections.
- Open bank bag slots with the Bank bags button; insert or change bags using the usual controls.
- Click a locked bank bag slot or drop a bag onto it to open Blizzard's purchase confirmation. The bag stays on the cursor.
- Access Blizzard's original bank view from settings.
- Optional sorting when opening bags or the bank, disabled by default. In combat only the display is sorted; stack merging runs outside combat.
- Larger Pawn upgrade arrows, including future upgrades above your current level, with a setting to hide them.
- Adjustable background transparency, including empty slots, and direct settings access from the bag window.
- Position, size and columns saved separately for each character, with separate bank geometry.
- Correct main-bank item tooltips and improved native drag/drop, merchant cursors and item highlights.
- `/ptbags debug` opens the shared diagnostic report with addon versions and load states.

Requires PatchTools. Recommended companion: PatchTools 0.9.0.

Validation: Classic Era gameplay testing by the maintainer and testers, plus automated inventory, bank and Era/Forever compatibility checks. Live Forever bank testing remains pending.

# PatchToolsBags 0.1.2-alpha.4 — 2026-10-27

- Add `/ptbags debug` for a copyable diagnostic report (requires the matching PatchTools update).
- Open and hide the bank bag slots with the Bank bags button in the title bar.
- Open Blizzard's original bank view from the bag settings.
- Click a locked bank bag slot, or drop a bag onto it, to open Blizzard's purchase confirmation. The bag stays on the cursor.
- Add optional sorting when bags or the bank are opened, disabled by default. In combat only the display is sorted; stacks are merged outside combat.

# PatchToolsBags 0.1.2-alpha.3 — 2026-10-27

Public alpha test: bugs are possible. The stable release remains available.

- Show equipped and locked bank-bag slots directly in the Classic Era bank window.
- Add the native bank-slot purchase button and price, keeping Blizzard's purchase confirmation.
- Fix tooltips for items in the main Classic Era bank storage.
- Show Pawn upgrade arrows even when the item requires a higher character level.

Please test bank-item tooltips, replacing bank bags and unlocking additional slots. Forever keeps its separate native bank-tab management. Automated interaction and restoration checks passed; in-game confirmation is pending.

Recommended companion: PatchTools 0.9.0-alpha.14. Report problems in the [PatchTools issue tracker](https://github.com/csBlackWolf/PatchTools/issues).

# PatchToolsBags 0.1.2-alpha.2 — 2026-10-27

Public alpha test: bugs are possible. Stable 0.1.1 remains available.

- Use a compact bank window in the PatchTools style, with search, sorting and separate specialty-bag sections.
- Remember bank position, size and item arrangement separately for each character. Background transparency follows your bag setting.
- Access the original bank controls through Bank setup, then return with `/ptbags bank`.
- Include separate bank support for Classic Era and Forever, keeping carried profession bags separate from bank storage.

Please test depositing, withdrawing, sorting and switching between the compact bank and Bank setup. Automated bank and bag checks passed; bank appearance and interactions still need in-game confirmation, especially on Forever.

PatchTools is required; the recommended companion is PatchTools 0.9.0-alpha.14. Report problems in the [PatchTools issue tracker](https://github.com/csBlackWolf/PatchTools/issues).

# PatchToolsBags 0.1.2-alpha.1 — 2026-10-26

Public alpha test: bugs are possible. Please report problems in the central PatchTools issue tracker. Stable 0.1.1 remains available.

- Add larger Pawn upgrade arrows at the bottom right of item icons. Enabled by default, with an option to switch them off. Pawn is optional.
- Add adjustable background transparency, including empty slots, while keeping occupied item icons readable.
- Add a borderless gear button that opens the bag settings directly.
- Remember window position, scale and column count separately for each character. Transparency remains shared.

PatchTools is required; the matching alpha is PatchTools 0.9.0-alpha.14.

Tested locally in Classic Era, with automated interaction, inventory and Pawn checks. Forever gameplay and character-switch layout persistence still need further in-game testing.

# PatchToolsBags 0.1.1 — 2026-10-25

- Restore the merchant sale cursor when hovering over bag items while the merchant's selling tab is open.
- Preserve spell-targeting cursors (including pet feeding), held-item cursors and repair mode; do not show a sale cursor on the buyback tab.
- Native item click and drag handlers remain unchanged.

Deutsch: Der Verkaufs-Mauszeiger erscheint jetzt auch im Taschenfenster beim
Händler. Füttern, Reparieren und gehaltene Items behalten ihren passenden Zeiger.

# PatchToolsBags 0.1.0 — 2026-10-25

First public release. **PatchTools is required.** This is an early version;
bugs and unfinished behavior are possible. Tested in Classic Era. Forever
compatibility is included but still needs separate in-game testing.

- Compact shared bag window in the PatchTools style, with individual specialty-bag sections.
- Sort on demand: arrange the display virtually and consolidate matching partial stacks. Other items retain their real inventory slots.
- Preserve manual placements across refreshes and reloads, separately for each character.
- Allow visual sorting in combat; skip stack consolidation with a short notice.
- Search, rarity and quest borders, readable sale/protection/quest markers and bag-information tooltips.
- Movable/scalable window, adjustable columns, and position/size reset in PatchTools settings or via `/ptbags reset`.
- Use native item click/drag handlers, including pet feeding, stack splitting and direct action-bar drops.
- Prevent lingering drag highlights without hiding the source button.
- English and German interface. No bank or offline-character storage yet.

Deutsch: Erster öffentlicher Release. PatchTools wird benötigt. Kompakte gemeinsame
Taschen mit getrennten Spezialtaschen, manueller Anordnung, visueller Sortierung,
Stapelzusammenführung, Suche und Itemmarkierungen. Im Kampf wird nur die Anzeige
sortiert. Früher Stand: Fehler sind möglich; Forever-Spieltests stehen noch aus.
