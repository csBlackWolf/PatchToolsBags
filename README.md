# PatchToolsBags

An independent optional bag module for [PatchTools](https://github.com/csBlackWolf/PatchTools).
**0.1.0-alpha.3 is an early alpha prototype for Classic Era; bugs and unfinished behavior are expected.** Forever
uses the additional profession bag when available, but needs its own in-game test.

Development takes place on `alpha/prototype`. This repository does not yet
provide a stable release.

## First test / Erster Test

Install PatchToolsBags alongside PatchTools, enable it in the addon list and open
it with `/ptbags`. A game restart may be necessary to discover a newly installed
addon. `/ptbags reset` restores position, size and columns.

PatchToolsBags neben PatchTools installieren und in der Addon-Liste aktivieren.
Mit `/ptbags` öffnen. Bei einem neuen Addon-Ordner kann ein Spielneustart nötig
sein. `/ptbags reset` setzt Position, Skalierung und Spalten zurück.

Other active bag addons take priority: while Baganator, Bagnon, AdiBags,
ArkInventory or BetterBags is loaded, the normal bag hotkeys are left to that
addon. `/ptbags` still provides a separate preview. Disable the other bag addon
and reload to test PatchToolsBags as the main bag window. No existing bag addon
or saved inventory data is automatically disabled or removed.

## Included

- One movable window, dark background and thin bronze border. Drag its lower right corner to scale it (65–130%).
- Carried bags with click-triggered visual sorting; adjustable scale and columns.
- Search by name, ID and item type. Search dims nonmatches without moving items.
- Search shortcuts: `quest`, `junk` / `schrott`, `sell` / `verkauf`,
  `protected` / `geschützt`.
- Click-triggered visual ordering by item class, subclass, name and full item link.
  Display slots retain their real bag/slot coordinates for clicks and dragging.
- Only identical partial stacks move physically when Sort is clicked. Other items
  retain their real slots. Saved display positions persist across refreshes and
  reloads per character, so manual dragging is not undone by automatic sorting.
- General bags share a section; each specialty bag has its own named section
  within the same window. Specialty families remain separate for consolidation.
  No bank or equipped items are touched.
- Native game icons mark quest items (!), protection (key), sale candidates
  (gold coin) and junk (the same coin in grey). Quest/protection take precedence.
  Markers sit inside the border with a soft black silhouette outline. Rarity
  and quest borders use Blizzard's rounded icon-frame artwork; quest borders are gold.
- Section names are replaced by a small bag icon on the left, with the free slot
  count below. Hover for totals and all bag names in that section. Specialty bags
  use their equipped bag icon when available, with explicit quiver/ammo-pouch
  icons for those types. Section icons are 18px.
- Compact one-pixel spacing with full-size 36px item buttons, slot counts and money on one
  footer line, and a ? tooltip for marker explanations and quick help.
- Item quality borders, stack counts and cooldowns.
- Standard click/drag, Shift stack split and modified item link interactions
  use Blizzard's container handlers. Selling/equipping requires normal user actions.
- Settings register with PatchTools through extension API 1.

## Limits and safety

Visual sorting happens only on a Sort click and does not move inventory items
or wait for the server. It also works in combat, with a chat notice that stack
merging is skipped. No delayed merging is queued for the end of combat. Physical
stack consolidation is explicit, outside combat, with an empty cursor. It stops for locked
or uncached items, unexpected inventory changes or unconfirmed movements. Close
the window to stop further movements; an already completed movement is retained.
It never clears the cursor, deletes, equips, uses or sells items automatically.
Do not interact with other inventory windows during sorting.

Bank, keyring, virtual categories and offline character inventories are outside
this first prototype. Bag replacement is optional. Very large combined tooltip
groups can exceed screen width; in-game compatibility testing remains required.

This is original addon code using Blizzard APIs and native item-button templates;
it does not embed another bag addon's implementation. No Syndicator dependency.

## Development

`python tests/run.py` requires Python and `lupa` (Lua 5.4). Tests cover randomized
visual ordering and slot identity, merge-only conservation across item variants/families, protection rules,
module registration, UI creation, bag access and inventory movement execution.
They do not replace an in-game test of protected actions and tooltip integrations.
