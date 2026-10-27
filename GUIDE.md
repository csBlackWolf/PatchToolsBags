# PatchToolsBags user guide / Bedienungsanleitung

## English

Install PatchToolsBags alongside PatchTools in the same client's `Interface/AddOns` folder and enable both. Restart the game if it does not yet recognize the new addon folder. Open the window with `/ptbags`; drag the title to move it and the lower-right corner to scale it. Settings in PatchTools also let you change the columns. `/ptbags reset` restores position, scale and columns, keeping your item layout.

Click **Sort** when you want to reorganize the window and combine partial stacks. Items remain where you placed them until you sort again. General bags share a section; specialty bags have separate sections. Hover over a section's bag icon for its bag names and free-space totals. The small number below it shows free slots.

Search by item name, ID or type. Shortcuts include `quest`, `junk`, `sell` and `protected`. Search dims other items without moving them. The **?** button explains the markers: quest, protected, marked for sale and junk. Quest items have gold borders; other quality borders match rarity. Stack counts and cooldowns work as usual.

Use normal clicks, dragging, Shift stack splitting and modified clicks for item links. At a vendor the cursor shows when an item can be sold. Selling/protection markers follow the rules in PatchTools; a marker does not sell anything by itself. Shift pauses PatchTools vendor automation for that visit.

Automatic sorting when opening bags or the bank can be enabled in settings and starts disabled. You can sort the display in combat. Stack merging is skipped, with a chat notice; it is not queued for later. Closing the window stops further stack merging. Avoid using another inventory window while merging is running.

Other active bag addons take priority over normal bag hotkeys. With Baganator, Bagnon, AdiBags, ArkInventory or BetterBags loaded, `/ptbags` still opens this window separately. To use PatchToolsBags for normal bag keys, disable the competing bag addon and reload. PatchToolsBags does not disable other addons or remove their saved data.

The bank view adds a separate compact window while visiting the banker, with search, Sort and specialty-bag sections. Position and scale are saved separately from your bags. Right-clicks and dragging use the normal bank actions. **Bank bags** shows or hides Classic Era bank bag slots. Click a locked slot, or drop a bag onto it, to request a purchase with confirmation. The bag remains on the cursor. The original Blizzard bank is available from settings; `/ptbags bank` returns to the compact view during the same visit. The bank view can be disabled in settings. `/ptbags reset` resets both window sizes and positions, retaining item layouts. Keyrings, warbanks and offline characters are not included. Classic Era has received in-game checks. Forever includes the extra profession bag where available, but still needs a separate in-game check. Very large tooltip groups may exceed the screen; include your tooltip addons and UI scale when reporting a problem.

## Deutsch

Installiere PatchToolsBags neben PatchTools im `Interface/AddOns`-Ordner desselben Clients und aktiviere beide Addons. Starte das Spiel neu, falls der neue Addon-Ordner noch nicht erkannt wird. Mit `/ptbags` öffnest du das Fenster. Ziehe die Titelleiste zum Verschieben und die Ecke unten rechts zum Skalieren. Die Spaltenzahl lässt sich in PatchTools einstellen. `/ptbags reset` setzt Position, Skalierung und Spalten zurück; deine Item-Anordnung bleibt erhalten.

Klicke auf **Sortieren**, um die Anzeige zu ordnen und angebrochene Stapel zusammenzuführen. Bis zum nächsten Sortieren bleiben Items an den von dir gewählten Plätzen. Normale Taschen teilen sich einen Bereich; Spezialtaschen haben eigene Bereiche. Am Taschen-Icon stehen die freien Plätze. Der Tooltip nennt alle zugehörigen Taschen und die Gesamtzahlen.

Suche nach Namen, Item-ID oder Itemtyp. Auch `quest`, `schrott`, `verkauf` und `geschützt` funktionieren. Andere Items werden abgedunkelt, ohne ihre Position zu ändern. Der **?**-Button erklärt die Markierungen. Questitems bekommen einen goldenen Rahmen; andere farbige Rahmen zeigen die Seltenheit.

Klicken, Ziehen, Stapel mit Shift teilen und Itemlinks funktionieren wie gewohnt. Beim Händler zeigt der Mauszeiger verkaufbare Items an. Verkaufs- und Schutzmarkierungen folgen deinen PatchTools-Regeln; die Symbole allein verkaufen nichts. Halte beim Öffnen des Händlers Shift, um die PatchTools-Verkaufs- und Reparaturautomatik für diesen Besuch zu pausieren.

In den Einstellungen kannst du das Sortieren beim Öffnen von Taschen und Bank einschalten. Anfangs ist es ausgeschaltet. Die Anzeige lässt sich auch im Kampf sortieren. Stapel werden dabei nicht zusammengeführt; darauf weist eine Chatnachricht hin. Es wird keine Zusammenführung für später vorgemerkt. Schließt du das Fenster, werden keine weiteren Stapel zusammengeführt. Benutze währenddessen möglichst kein anderes Inventarfenster.

Andere aktive Taschen-Addons behalten die normalen Taschen-Tasten. Mit `/ptbags` kannst du dieses Fenster separat öffnen. Deaktiviere das andere Taschen-Addon und lade die Oberfläche neu, wenn PatchToolsBags die normalen Taschen-Tasten übernehmen soll. Bestehende Addons und deren gespeicherte Daten werden nicht entfernt.

Die Bankansicht ergänzt beim Bankier ein eigenes kompaktes Fenster mit Suche, Sortieren und Bereichen für Spezialtaschen. Position und Skalierung werden getrennt von deinen Taschen gespeichert. Rechtsklick und Ziehen verwenden die normalen Bankaktionen. **Banktaschen** blendet in Classic Era die Banktaschenplätze ein oder aus. Ein Klick auf einen gesperrten Platz oder das Ablegen einer Tasche darauf öffnet die Kaufbestätigung. Die Tasche bleibt am Mauszeiger. Blizzards ursprüngliche Bankansicht erreichst du über die Einstellungen. Mit `/ptbags bank` kehrst du während desselben Besuchs zur kompakten Ansicht zurück. Die Bankansicht lässt sich in den Einstellungen ausschalten. `/ptbags reset` setzt Größe und Position beider Fenster zurück; Item-Anordnungen bleiben erhalten. Schlüsselbund, accountweite Bank und Inventare ausgeloggter Charaktere sind nicht enthalten. Classic Era wurde im Spiel getestet. Die zusätzliche Berufstasche auf Forever wird berücksichtigt, benötigt aber noch einen eigenen Spieltest. Bei Problemen mit großen Vergleichstooltips helfen Angaben zu deinen Tooltip-Addons und deiner UI-Skalierung.

## Further reading / Weitere Informationen

[Developer guide](DEVELOPMENT.md) · [Changelog](CHANGELOG.md) · [Report a bug](https://github.com/csBlackWolf/PatchTools/issues/new/choose) · [Back to overview](README.md)
