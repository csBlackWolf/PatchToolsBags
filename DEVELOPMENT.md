# Developing PatchToolsBags

PatchToolsBags is a separate optional PatchTools module. This guide explains the implementation and the checks needed when changing it. Start with the [user guide](GUIDE.md) for controls and current limits.

## Source layout

- `Core.lua` handles initialization, events and bag-window integration.
- `Model.lua` classifies items, filters searches, plans display order and stack merging.
- `Window.lua` builds and refreshes the bag window and its native item buttons.
- `Pawn.lua` uses the optional public Pawn bag-arrow API, caches completed answers, retries budgeted results and invalidates on Pawn callbacks. Register with Pawn only while replacing the native bag window.
- `Options.lua` registers settings with PatchTools extension API 1.
- The TOC defines dependencies, load order and saved variables.

Keep real bag/slot identity separate from display position. Visual sorting orders existing slot records; it must not turn a click on one icon into an action on another slot. Save display positions per character and retain manual placement until the next explicit Sort click. Group general bags together and keep specialty families separate.

## Inventory actions

Only identical partial stacks move physically when Sort is clicked. Match the full item variant and bag family, preserve item counts, and stop for combat, a nonempty cursor, locks, missing cached data, unexpected inventory changes or an unconfirmed move. Closing the window stops subsequent movements. Do not queue merging after combat or clear a player's cursor.

Use Blizzard's native container-item handlers and secure button behavior for clicks, drag/drop, feeding, equipping, selling and stack splitting. Calling protected item-use functions through an ordinary custom click handler can fail even when the click itself came from the player. Test native cursor behavior at a vendor as well as the item action.

Do not automatically delete, equip, use or sell items. PatchTools owns vendor automation and selling lists. Quest/protection rules take precedence over sale/junk markers. This module uses Blizzard APIs and artwork; it does not include another bag addon's implementation or require Syndicator.

## Rendering

Use rounded native icon-frame artwork for rarity and quest borders. Keep overlay markers inset from the top and left edges, with a soft black silhouette for contrast. Junk uses the same coin shape as sale markers, desaturated. Section icons stay small, with free-space counts and a tooltip listing the bags.

Native item-button templates contain glow, flash and hover decorations. Clear stale state when moving or reusing buttons, including empty slots; do not leave hover highlights at a previous display position. Preserve native cooldowns and stack counts. Test dragging straight from a bag slot to an action bar without an extra click.

## Tests

From the repository root, run `python tests/run.py` with Python and `lupa` (Lua 5.4). Fixtures cover randomized display ordering, slot identity, merge conservation across variants and bag families, protection rules, registration, window creation and inventory movement.

In-game checks still matter for protected actions, feeding, vendor cursors, combat sorting, drag/drop, tooltip comparisons and other bag addons. Report which client, build, addon combination and UI scale you actually tested. Automated fixtures do not establish visual or gameplay compatibility.

## Releases and contributions

Public releases use `main`; `alpha/prototype` preserves the initial prototype history. Keep technical explanations here and practical controls in [GUIDE.md](GUIDE.md). The README is the short player-facing presentation shared with CurseForge.

See [RELEASING.md](RELEASING.md) for packaging and publication, [CHANGELOG.md](CHANGELOG.md) for changes and the [PatchTools extension guide](https://github.com/csBlackWolf/PatchTools/blob/main/EXTENSIONS.md) for settings integration. Keep commit messages and documentation direct: describe the change and its purpose without conversational notes or assumptions about who is doing the work.
