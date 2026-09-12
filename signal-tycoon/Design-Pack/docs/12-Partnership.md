# 12 · Partnership Panel

**Intent.** Give both players a clear account of shared responsibilities, their own contributions and what happens when they leave. Hosting rights are stated plainly instead of visually implying equal ownership of permanent upgrades.

**Specification.** Host and Co-owner cards have name, avatar, role and online state. Show each player’s confirmed Credit contributions, production contributions and server-provided cap usage. Show shared cap alongside account remaining allowance; forming a partnership must not appear to replenish either. Pending upgrade vote shows item, total cost, each contribution, two acceptance indicators and server deadline. The panel supports request, accept/decline, vote and dissolve views; eligibility and expiry are server-owned.

**Dissolution.** Step 1 shows who retains plot/upgrades, each player’s projected refund and handling of active jobs. Step 2 is an explicit final confirmation after the server-supplied 60-second cooling period. Closing the panel does not bypass or restart the authoritative deadline. Never compute refunds locally. Rebirth is an engineer-owned progression flow; this panel may show its requested mutual confirmation and reset summary without implementing it.

**States.** Solo/ineligible, request pending/expired, active, partner offline, vote pending/declined/expired, dissolution review/cooling/ready/submitting/completed. A v2 source conflict says dissolution is available at any time but also requires both players present. The UI accepts a server `canDissolve` reason and presents that actual condition; it does not silently choose an engineering rule.

**Wireframe.** `UI-Wireframes.html#PartnershipPanel`.

**Luau.** `PartnershipUIController.lua` emits partnership request/accept/decline, upgrade vote, dissolve preview/final intents with request/vote/review IDs. Both contributor cards and cap fields are read-only server projections. Offer/quote version changes invalidate UI confirmations.

**Assets.** Original two-person role icons, Pulse nameplate, A04 confirmation controls and A06 confirmation/cancel sounds. Avatar images must be actual resolved thumbnails, never arbitrary asset IDs.

**Test notes.** One player disconnects during a vote, a vote expires while panel closed, dissolve deadline passes with stale state, and contribution state updates after a purchase. Controller cancellation must focus Cancel first in destructive review.

**Open questions.** Engineer/design owner must resolve offline dissolution and ownership of the single collectible from a partnered production before V3. Neither blocks the design system or solo MVP; production must show a server-confirmed designated Drop owner before starting.
