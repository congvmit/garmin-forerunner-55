# Daily55

A daily watch face project for the **Garmin Forerunner 55** (`fr55`), built with Monkey C / Connect IQ.

Daily55 has two build-selected UIs sharing one watch-face controller and data pipeline:

- **Analog (default):** black dial with cyan radial dots, rounded hour/minute hands, date, notification count, Bluetooth, battery, and recorded heart rate. Hands draw above the data fields, so they can overlap them. A white dotted seconds spoke appears while awake.
- **Digital:** black background, large cyan `HH:MM`, date, the same status row and heart-rate field, AM/PM in 12-hour mode, and small white seconds while awake. It respects the device's 12/24-hour preference and measures native numeric fonts during layout.

Only the selected UI's source and private resources are compiled into its binary. Both variants use the same application ID and name: installing another variant replaces Daily55; they do not coexist or switch through app settings. The target remains FR55, minimum API 3.2.0, with no permissions added.

Both UIs use the system update lifecycle without timers or low-power partial updates. Seconds disappear in low-power mode. Shared bundled 12/20 px bitmap fonts keep small fields consistent across device languages.

Heart rate is read from `ActivityMonitor.getHeartRateHistory`, refreshed once per minute and on wake. Invalid, missing, future-dated, and more-than-five-minute-old samples are rejected; unavailable readings display `-- bpm`. This is recorded heart rate, not a continuously requested sensor reading. Notifications are capped at `99+`; battery fill is clamped to 0–100%.

## Environment installed on this machine

- Homebrew OpenJDK **17.0.21.0.3**, registered at `~/Library/Java/JavaVirtualMachines/openjdk-17.jdk`; `java -version` works.
- Garmin SDK Manager at `/Applications/SdkManager.app`.
- Connect IQ SDK **9.3.0**, set as the current SDK; the **fr55** device package, API **3.4.2**, has been downloaded.
- VS Code extension **garmin.monkey-c 1.1.3**.
- Signing key at `keys/developer_key.der`, in PKCS#8 DER format, using RSA 4096 bits and file permissions `600`. Do not share or commit this key.
- `.vscode/settings.json` configures Java and the signing key for this machine. It contains local paths and is excluded by `.gitignore`.

Open the project in VS Code, open `source/Daily55View.mc`, and press **F5** to launch the simulator configuration. If VS Code has not picked up the new extension, run **Developer: Reload Window**. Use the steps below when setting up the environment again or moving to another machine.

## Setup on macOS

1. Install Java JDK 17, for example from [Eclipse Temurin](https://adoptium.net/temurin/releases/?version=17), then verify it with `java -version`.
2. Install [Garmin Connect IQ SDK Manager](https://developer.garmin.com/connect-iq/sdk/). Sign in to your Garmin account, download an SDK, and set it as the current SDK. In the **Devices** tab, download **Forerunner 55**.
3. Open the project folder in VS Code and install Garmin's **Monkey C** extension (`garmin.monkey-c`), which the project recommends.
4. Open the Command Palette (`Cmd+Shift+P`) and run **Monkey C: Verify Installation**.
5. Run **Monkey C: Generate a Developer Key**. Save the key in the project's `keys/` directory or a private location outside the project, and configure **Monkey C: Developer Key Path** if needed. `keys/`, `*.der`, and `*.pem` are already excluded by `.gitignore`. Keep a backup of the key to sign future updates.

## Run the simulator

1. Open `source/Daily55View.mc` in VS Code.
2. Press `F5`, select **Run Daily55 on Forerunner 55** if prompted, then select **Forerunner 55**.
3. The default Jungle file selects analog. Check hand positions, status indicators, valid/unavailable heart rate, and awake/sleep transitions. The analog dial uses a 12-hour cycle for either device time-display setting. Use the CLI commands below to build and run either UI explicitly.

The manifest targets only `fr55`. The watch face uses the system's `onUpdate` callback without custom timers or animations. In low-power mode, the system updates the watch face once per minute.

## Build and install on the watch

1. Connect the watch to your computer using a data cable.
2. Run **Monkey C: Build for Device**, select **Forerunner 55**, and choose `bin/` as the output directory.
3. Copy the generated `.prg` file to `GARMIN/APPS` on the watch when its storage is accessible from your computer.
4. Safely disconnect the watch. From the watch face, hold **UP**, open **Watch Face**, select **Daily55**, and apply it.

On macOS, access to the watch's storage depends on its connection mode. If the drive does not appear in Finder, check the USB connection and Garmin's instructions before copying the file.

## Build either UI

Discover the installed SDK and use the existing signing key from the repository root:

```sh
GARMIN_SDK_DIR="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
mkdir -p bin
"$GARMIN_SDK_DIR/bin/monkeyc" -f monkey.jungle -d fr55 -y keys/developer_key.der -o bin/Daily55-analog.prg -w
"$GARMIN_SDK_DIR/bin/monkeyc" -f monkey-digital.jungle -d fr55 -y keys/developer_key.der -o bin/Daily55-digital.prg -w
"$GARMIN_SDK_DIR/bin/connectiq"
# After the simulator opens, run ONE variant:
"$GARMIN_SDK_DIR/bin/monkeydo" bin/Daily55-analog.prg fr55
# Or, after File > Kill App:
"$GARMIN_SDK_DIR/bin/monkeydo" bin/Daily55-digital.prg fr55
```

`monkeydo` remains connected while the face runs. Stop the previous app with **File > Kill App** before loading another build. For sideloading, use the chosen variant's binary; its application identity is the same in either case.

## Code and layout contract

- `source/Daily55View.mc`: shared `WatchUi.WatchFace` lifecycle, heart-rate history cache, device queries, and rendering dispatch.
- `source/Daily55State.mc`: one reused snapshot of timestamp, clock, date, device time mode, sleep state, validated HR and formatted fields, connection status, and clamped battery. The controller updates it before every render; layouts treat it as read-only.
- `source/Daily55Data.mc`: heart-rate validation and status limits.
- `source/Daily55Time.mc`: digital time and AM/PM formatting.
- `source/Daily55Drawing.mc`: shared notification, Bluetooth, and battery drawing. The caller sets the foreground/background colors; the status row uses the existing y=49..62 coordinates.
- `ui/analog/` and `ui/digital/`: mutually exclusive layout implementations and private resources.
- `resources/`: common launcher icon, app name, and bitmap fonts.
- `source/Daily55App.mc`, `manifest.xml`: shared application entry point and identity.
- `tools/GenerateAssets.java`: bitmap font and analog background generator; edit it instead of generated assets.

Each UI defines exactly one class named `Daily55Layout`:

```text
initialize()               Create lightweight layout state.
loadResources(dc)          Load/cache resources and measure fonts; safe to call again.
render(dc, state)          Clear and draw a complete frame using Daily55State.
```

Layouts do not query sensors, refresh metrics, schedule timers, or own sleep callbacks. They read `state.clock.hour/min/sec`, `state.date`, `state.dateText`, `state.is24Hour`, `state.sleeping`, `state.heartRate` (number or null), `state.heartRateText`, `state.notifications` (capped text), `state.phoneConnected`, and `state.battery` (0–100).

### Add a third UI

1. Create `ui/<name>/source/Daily55Layout.mc` implementing the contract, and `ui/<name>/resources/` for its resource definitions and artwork. Give private resources distinct IDs; keep common fonts/icon/strings shared.
2. Copy the root digital Jungle configuration into `monkey-<name>.jungle`; replace both `ui/digital` paths with `ui/<name>`. Keep `source` and `resources` as the common inputs. Do not include another UI directory or change the manifest identity.
3. Copy the digital test Jungle file and select the new UI paths. Build and run its tests and binary using a distinct name under `bin/`.
4. Inspect native 208 × 208 simulator captures, awake/sleep behavior, metric limits, and memory before considering the UI verified. If generated artwork is needed, extend the generator to write into that UI's resource directory.

## Assets and focused tests

Regenerate the background and bitmap fonts from the repository root with the installed JDK:

```sh
java -Djava.awt.headless=true tools/GenerateAssets.java
```

The generator writes the radial background to `ui/analog/resources/drawables/radial_dots.png` and shared fonts to `resources/fonts/`. It uses the bundled [Barlow Condensed Regular](https://github.com/google/fonts/tree/main/ofl/barlowcondensed) font. Its original font and generated bitmap derivatives are covered by the [SIL Open Font License](tools/fonts/OFL.txt). No additional Java libraries are required.

Build and run the focused data tests in an open simulator (stop the running face first using **File > Kill App**):

```sh
GARMIN_SDK_DIR="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
"$GARMIN_SDK_DIR/bin/monkeyc" -f tests/test.jungle -d fr55 -y keys/developer_key.der -o bin/Daily55-analog-tests.prg -t -w
"$GARMIN_SDK_DIR/bin/monkeydo" bin/Daily55-analog-tests.prg fr55 -t
"$GARMIN_SDK_DIR/bin/monkeyc" -f tests/test-digital.jungle -d fr55 -y keys/developer_key.der -o bin/Daily55-digital-tests.prg -t -w
"$GARMIN_SDK_DIR/bin/monkeydo" bin/Daily55-digital-tests.prg fr55 -t
```

Both test configurations include the same seven tests: the original four data tests, cached-HR expiry in the shared snapshot, and two digital-time tests covering midnight/noon, afternoon, leading zeros, 12/24-hour modes, and AM/PM. Production builds exclude the test directory. The SDK launcher currently returns exit status 1 even when it prints `PASSED (passed=7, failed=0, errors=0)`; inspect the full test summary rather than treating that exit as a test assertion failure.

## Verification status

### Multiple-UI implementation (5 November 2026)

- Both production variants and both test variants build for FR55 with SDK 9.3.0 and warnings enabled: **BUILD SUCCESSFUL**, without warnings.
- Both variants pass all **seven runtime tests** (`passed=7, failed=0, errors=0`). The final digital test binary was rerun after the font-selection adjustment; the launcher still exits 1 after reporting success, as in the original implementation.
- Compiler debug symbols confirm that each binary contains only its selected layout; `RadialDots` is present in analog and absent in digital. The moved/regenerated background matches the original file byte-for-byte; shared generated fonts are unchanged.
- The refactored analog native screenshot at 10:10 (`bin/daily55-analog-matched-1010.png`) is byte-for-byte identical to the exact baseline build (`bin/daily55-multi-before-1010.png`). Both show unavailable HR and the same status values.
- Analog simulator memory showed **20.4 kB current / 22.2 kB peak**, with zero new resource allocations in the last update. A preliminary digital build showed **14.4 kB current / 16.0 kB peak**. These are simulator-reported units and single-session observations, not hardware battery or memory-stability measurements.
- The first digital font-fit loop tripped the startup watchdog; bounded hour/minute component measurement fixes that observed crash. Runtime font probing found numeric font line heights of 90/79/37 px and longest time widths of 176/158/72 px. The final selector accommodates that leading and selects the largest numeric font whose full line box fits the dial.
- Preliminary digital captures exercised a small clock, PM, seconds, unavailable HR, empty battery, and disconnected Bluetooth. The simulator notification dialog clamps 100 to 20, so it cannot directly verify the `99+` visual state.
- **Final visual verification is pending:** the Mac locked before the final larger clock and explicit rendering fixtures could be captured. Fixture binaries under ignored `bin/ui-verification/` cover digital midnight/noon/23:59, analog 06:30/noon, `99+`, HR 199/unavailable, connection/battery limits, and repeated real controller sleep/wake callbacks. Those fixtures have compiled but have not been observed running. A later access retry timed out during automatic permission review, and its single retry failed while initializing the computer-use server. Final digital screenshots, those edge-state screenshots, and repeated-cycle memory checks remain unverified until simulator UI access is restored.

### Original analog implementation (5 November 2026)

- The final analog face builds for `fr55` using SDK 9.3.0: **BUILD SUCCESSFUL**, without compiler warnings.
- The face was loaded on the **Forerunner 55 (3.4.2)** simulator. The cyan radial texture, rounded hands, date, status icons, valid simulated HR, unavailable HR, and white seconds spoke were observed.
- The final 10:10 native-resolution capture was saved locally at `bin/daily55-analog-final-1010.png`. The historical digital-face capture is preserved at `bin/daily55-digital-before.png`.
- The simulator displayed approximately **18.5 KiB** in use, below the device's **96 KiB** watch-face limit. This is a single-session observation, not a memory-leak or battery-life measurement.
- All four focused Garmin runtime tests reported **PASS**: invalid sample skipping, missing/expired samples, freshness boundaries including future timestamps, and notification/battery limits. The test build had no compiler warnings. The SDK launcher returned exit status 1 despite reporting `PASSED (passed=4, failed=0, errors=0)`; the launcher exit remains unresolved.

The simulator time-control window became unresponsive during reload, and the verification session was interrupted. Visual checks at noon, 06:30, and 23:59; notification/Bluetooth/battery state combinations; repeated wake/sleep behavior; and memory stability across those cycles remain outstanding. The data-limit tests do not establish those visual outcomes.

Builds and screenshots in `bin/` are local outputs and are not committed. Physical-watch readability, actual battery consumption, and installation on hardware have not been verified. The VS Code configuration is prepared; recorded build and runtime checks used the CLI.

## Garmin documentation

- [Getting started with Connect IQ](https://developer.garmin.com/connect-iq/connect-iq-basics/getting-started/)
- [Creating a project, running the simulator, and sideloading](https://developer.garmin.com/connect-iq/connect-iq-basics/your-first-app/)
- [WatchFace lifecycle and updates](https://developer.garmin.com/connect-iq/api-docs/Toybox/WatchUi/WatchFace.html)
- [Device specifications](https://developer.garmin.com/connect-iq/compatible-devices/)
