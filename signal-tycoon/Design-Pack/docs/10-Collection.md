# 10 · Collection

**Intent.** Make each Drop identifiable and protect collections from accidental salvage. Studio souvenirs and tradable Weekly editions have unmistakably different series/status labels.

**Specification.** Filter category, series, rarity and favourites; page results rather than instantiating the entire inventory. Phone uses a full-width result row with category, series, rarity word/shape; selecting opens a detail section containing quality, creation time, original creator, current owner and eligibility. Desktop can use two columns. Every row has a 48px selection target; favourite is a separately labelled action, not a hover star. Detail footer has Favourite/Unfavourite and Salvage preview; large inventories use a next-page button with loading feedback.

**States.** Empty collection offers Produce. Pending Weekly displays pending settlement and disables salvage/trade. Favourite or transaction-locked items explain protection. Salvage preview shows the exact server-supplied Credit reward and the item identity, then requests a second confirmation. Cancelling is safe. Only an acknowledged inventory update removes the card; timeout keeps the item visible with status unknown, not a second automatic request.

**Wireframe.** `UI-Wireframes.html#CollectionPanel`; twelve base card combinations in `Card-Treatments.html`.

**Luau.** `CollectionUIController.lua` sends `collection.query`, `collection.select`, `collection.favourite`, `collection.salvageQuote`, `collection.salvage`. Pass dropId, expected ownership/version and quote token as opaque server references. UI never grants salvage Credits. Timestamps are displayed from localised date/time text projected by the adapter or formatted with approved localisation patterns.

**Assets.** Three category artworks, four rarity shapes, shared card border; A04 panel/check controls; A06 cancel/confirmation. Reuse the same assets for plinth display and marketplace detail.

**Test notes.** Filter every series; inspect Epic in greyscale; display very old creation dates and long filtered creator names. Attempt salvage on favourite/pending/listed objects. Controller returns focus to the selected card or nearest surviving row after an acknowledged removal.

**Open questions.** None blocking UI. Initial page size target: 20 results; backend pagination remains an engineer choice.
