# Store Launch Checklist

One file: **[store-launch-checklist.html](./store-launch-checklist.html)**. Double-click to open it (Chrome or Edge). No server and no build step. The only network request is the Google Fonts stylesheet, which falls back to system fonts offline; nothing is ever sent anywhere. The interface runs in English or Indonesian — the toggle in the top bar switches the interface *and* the content.

## What is inside

| Part | Nature |
|---|---|
| **Checklist** tab — 60 release-preparation points across 9 sections. Points whose rules differ per platform carry Android and iOS tabs. Progress per section, filter, print mode | **Fixed.** Identical in every project |
| **Privacy template** button — a generic privacy policy in Indonesian and English, plus the data deletion request page, all copyable | **Fixed.** Fill the `<...>` placeholders, drop the data categories your app does not collect |
| **Audit** tab — repository identity, coded findings (B/H/M) with their fixes, a list of what is already correct, and project data cards. Every finding is tickable once fixed, has its own progress, and jumps straight to the checklist point it belongs to — the point links back with the finding codes | **Generated.** Empty in a clean file, and the tab does not appear |
| **Reference** tab — guidance matching the project's stack | **Generated.** Empty in a clean file, and the tab does not appear |

The two generated tabs carry a blue dot, and each of their cards is labelled `generated`, so it stays obvious which content ships with the file and which came from auditing a specific repository.

## Status lives in the file, not in the browser

Three data blocks sit at the top of the `<script>`, between the `PROJECT-LAYER-START` and `PROJECT-LAYER-END` markers:

```js
const PROJECT = { app:"", updated:"", done:[], fixed:[], notes:{} };  // app, date, ticked points, closed findings, per-point notes
let AUDIT = null;                                                    // findings plus the project data cards
let REF = [];                                                        // reference cards
```

Ticks — both checklist points and fixed findings — are temporary in the browser; reload the page to discard them. What persists is the file itself, and the page can rewrite that file:

- **Save to file** → **Save file**: rewrites `store-launch-checklist.html` with the current status. Only the `PROJECT` block is rewritten, so `AUDIT` and `REF` keep their formatting and the git diff stays small. The same dialog also offers **Copy** if you would rather paste the snippet by hand.
- **Reset**: confirm, and the file is immediately overwritten in a clean state — ticks, notes, findings, and reference cards leave the file, not just the screen.

The browser asks for the file **once**. The first save opens a file dialog; pick the file itself and approve the replacement. The handle is remembered from then on, so every later save overwrites it with no dialog — at most a small "edit this file?" permission chip after you reopen the page. Move or rename the file and the page simply asks for it again.

> Over `file://` Chrome refuses to write at all, so the file lands in Downloads and you replace the old one yourself. The toast at the bottom of the screen always says which of the two happened. Serving the folder over a local server — `python3 -m http.server` in `docs/release/` — is what unlocks in-place saving.

Never delete the `PROJECT-LAYER-START` / `PROJECT-LAYER-END` markers — they define the region that gets overwritten.

## Running the prompt

1. **Copy the file** into the target project:
   ```bash
   mkdir -p docs/release && cp /path/to/store-launch-checklist.html docs/release/
   ```
2. **Open Claude Code at that project's root** (`claude` in a terminal, or open the folder in the Claude Code app).
3. **Paste the prompt below** as-is and send it. There is no need to clear the file first — the prompt handles that.
4. **Wait.** Claude reads the manifests, plists, gradle files, entitlements, permission code, and icon assets, runs the analyzer, and writes the results into the `PROJECT`, `AUDIT`, and `REF` blocks inside the HTML file.
5. **Open `docs/release/store-launch-checklist.html`** in a browser. The Audit and Reference tabs now appear, and the ring at the top left shows how many of the 60 points are already satisfied.
6. **Commit the file** so the whole team sees the same status.

### The prompt

```text
This repository contains docs/release/store-launch-checklist.html — an App Store and
Google Play release checklist with 60 points. Run that checklist against this
repository, turn it into an audit, and write the results back into that HTML file.

Steps:
1. Read the HTML file first: the DATA array (60 points, each with an Android and an
   iOS panel), then the PROJECT, AUDIT, and REF blocks you are going to fill.
2. Clear any previous project data: PROJECT becomes
   { app:"", updated:"", done:[], fixed:[], notes:{} }, AUDIT becomes null, REF
   becomes [].
3. Check this repository against every point. At minimum, open:
   - pubspec.yaml / package.json: version, dependencies, bundled assets
   - android: AndroidManifest.xml (every flavor), build.gradle(.kts) — applicationId,
     minSdk/targetSdk, release signingConfigs, ProGuard/R8
   - ios: Info.plist (purpose strings, orientation, ATS, background modes),
     *.entitlements (aps-environment), project.pbxproj (bundle id, device family,
     deployment target, signing), and whether PrivacyInfo.xcprivacy exists
   - code: which permissions are actually requested and when, what data is sent to the
     server, third-party SDKs, whether an account deletion path and privacy policy
     link exist
   - icon and screenshot assets: dimensions and alpha channel
     (sips -g pixelWidth -g pixelHeight -g hasAlpha)
   - run the analyzer/linter and report what it says
4. Fill the PROJECT block:
   - app: the app's public name, updated: today's date, fixed: [] (it stays empty —
     findings get ticked later in the Audit tab as they are fixed)
   - done: ONLY points that are genuinely satisfied and that you verified in code or
     configuration. Never tick anything on assumption.
   - notes: a short note per point in both languages (id and en), using k:"ok" for a
     point that is done together with the reason, k:"todo" for a finding, and k:"blk"
     for a blocker.
5. Fill the AUDIT block:
   - repo, commit, date, identity (an identity and configuration table with file:line
     sources)
   - findings: code them B1..Bn for blockers (submission will fail or be rejected),
     H1..Hn for high risk, M1..Mn for release hygiene. Each finding carries where
     (file:line), t (title, id+en), f (the fix, id+en), code (a fix snippet where one
     helps), and item (the id of the related checklist point from DATA — always set
     this, it is what links the finding to its point in both directions).
   - ok: the things that are already correct, in both languages
   - AUDIT.cards: the distribution route chosen for this project and why, App Privacy
     and Data Safety answers mapped from the code, store listing copy, a screenshot
     plan, the demo account and review notes, and the release runbook
6. Fill the REF block with reference cards that suit this project's stack — for
   example the correct release build commands, a realistic timeline, and the most
   common rejection causes.
7. Do not touch the DATA array or the PRIVACY object, except for the <...>
   placeholders in PRIVACY that must carry this company's details.
8. Verify the result: open the file in a browser, confirm there are no console errors,
   that all three tabs render correctly in both languages, and that the tick count
   matches the findings.
9. Summarise for me: how many of the 60 points are done, the list of blockers, and the
   order of work you recommend.

Rule: every "already done" claim needs file:line evidence. Anything that cannot be
verified from the repository — whether the privacy policy URL is live, for instance —
is marked todo, not done.
```

### Keeping it current

```text
Update the PROJECT and AUDIT blocks in docs/release/store-launch-checklist.html to
match the repository as it stands now: tick the points that are done, add the codes of
fixed findings to PROJECT.fixed, remove findings that no longer apply, and set updated
to today's date.
```
