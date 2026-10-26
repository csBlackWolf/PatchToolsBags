# PatchToolsBags 0.1.2-local.2 — local test — 2026-10-26

- Apply background transparency to empty slot fills and borders; keep occupied icons and rarity borders opaque.

# PatchToolsBags 0.1.2-local.1 — local test — 2026-10-26

- Add a bottom-right Pawn upgrade arrow using Pawn's bag advisor and settings.
- Keep stack counts clear of upgrade arrows and refresh after Pawn/equipment changes.
- Add background transparency and a gear button that opens the bag settings directly.
- Pawn remains optional. This build is for local testing, not a public release.

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
