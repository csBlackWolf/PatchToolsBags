# PatchToolsBags 0.1.2-alpha.2-local.1 — local bank preview — 2026-10-26

- Add a separate compact bank window with search, sorting and specialty-bag sections while visiting the banker.
- Store bank position, scale and item arrangement separately for each character; share background transparency with bags.
- Keep the native bank controls available through Bank setup and return with `/ptbags bank`.
- Handle Era bank bags and Forever purchased character-bank tabs separately; never treat the carried profession bag as bank storage.
- Add a bank-view toggle. Stop bank stack merging when the visit ends.

Automated bank and existing bag tests passed. Bank interactions and appearance still need in-game testing. This preview is local only.

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
