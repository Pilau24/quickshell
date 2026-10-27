## Plan: Clock popup dashboard (time, weather, calendar)

Clicking the bar clock opens a centered panel: a full-width time banner on top, a weather card on the left, and a month calendar on the right with prev/next buttons. Weather is static (25°C, Clear). The bar clock text stays as it is.

**Steps**
- [x] 1. Add theme colors to `Config.qml`: expose `surface`, `accent`, `text`, and `muted` as `panelSurface`, `accent`, `panelText`, and `muted`, using the same fallback pattern as `barBackground`.
  - Verify: `Config.qml` has the four new properties with fallbacks, and the file has no QML errors on reload.
- [x] 2. Create `components/widgets/ClockPanel.qml` with `config` and `clock` (the `SystemClock`) as required properties. Set `implicitWidth` and `implicitHeight`, since `WidgetPanel` sizes from the loaded content.
  - Verify: the file exists, both required properties are declared, and the implicit sizes are non-zero when the panel opens.
- [x] 3. Build the time banner: `Qt.formatTime(clock.date, "h:mm:ss AP")` in a large `config.barFont`, in a rounded full-width card.
  - Verify: the banner shows 12-hour time with seconds and the seconds tick.
- [x] 4. Build the weather card (left): moon glyph, "25°C", and "Clear". No network calls.
  - Verify: the card shows 25°C and Clear, and no `Process` or network code is present.
- [ ] 5. Build the calendar card (right): a header with `<` and `>` buttons and a "Month YYYY" title, a Su–Sa weekday row, and a 6×7 grid. Days come from `new Date(year, month, 1).getDay()`. Today is highlighted, and other-month cells are muted. Navigation state resets when the day changes.
  - Verify: the current month shows 2026-10-27 highlighted, Oct 1 2026 falls under Thu, and the grid has 42 cells.
- [ ] 6. In `ClockWidget.qml`, keep `timeContent` for the bar. Replace the `WidgetPanel` `content` with a `Component` that loads `ClockPanel` and passes `config` and `clock`. *Depends on 2–5.*
  - Verify: the bar still shows `hh:mm:ss`, and clicking the bar clock opens `ClockPanel`.
- [ ] 7. Layout: a Column with the banner on top and a Row below it (weather left, calendar right), 8px spacing. Cards use `config.panelSurface`, text uses `config.panelText`, and radius uses `config.roundingFactor`.
  - Verify: the banner spans the full width, the weather and calendar sit side by side, and the colors match the active theme.

Steps 1 and 2 can run in parallel. Steps 3–5 depend on 2. Mark each step `[x]` only after its Verify line passes.

**Relevant files**
- `components/widgets/ClockWidget.qml`: owns `clock`, `timeContent`, and the `WidgetPanel` whose `content` gets replaced.
- `components/core/WidgetPanel.qml`: the popup; its `Loader` sizes to `loader.implicitWidth + 16`.
- `components/core/Config.qml`: add color bindings next to `barBackground` and `barText`.
- `components/widgets/ClockPanel.qml` (new): panel content.
- `themes/*.toml`: no change. `surface`, `accent`, and `muted` already exist.

**Verification**
1. Ctrl+click the bar to reload, then check the Quickshell log for QML errors.
2. Click the clock. Confirm the seconds tick and the weather shows 25°C and Clear.
3. Confirm today (2026-10-27) is highlighted and the first row starts on the correct weekday.
4. Click `<` and `>`. Confirm the month and year roll over correctly, including December to January.
5. Press Escape or click outside. Confirm the panel closes.
6. Run `qmllint` on the changed files if it is available.

**Decisions**
- The banner uses 12-hour format to match the reference. The bar keeps `hh:mm:ss`.
- Weather is static, with a moon glyph for night.
- Weeks start on Sunday, matching the reference.
- Included: time banner, weather card, calendar with prev/next navigation.
- Excluded: media, system stats, profile card, Settings and Weather tabs, live weather, and Monday-start.

**Further Considerations**
1. Should clicking the calendar title return to the current month? Option A: yes. Option B: no, prev/next only (default).
2. Should weather values move into `config.toml`? Option A: keep hardcoded for now (default). Option B: add `weatherTemp` and `weatherLabel` keys.
