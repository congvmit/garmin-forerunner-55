# Daily55

A daily watch face project for the **Garmin Forerunner 55** (`fr55`), built with Monkey C / Connect IQ.

The watch face uses a black dial with cyan radial dots, rounded analog hour/minute hands, notification count, Bluetooth status, a battery icon, an English date such as `WED 8`, and the latest recorded heart rate. The hands draw above the data fields, so they may overlap a field at some times.

A white dotted seconds indicator appears while awake and is hidden in low-power mode. The face uses the system update lifecycle without timers or low-power partial updates. Static background artwork and bundled 12/20 px bitmap fonts keep the layout consistent across device languages.

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
3. Check analog hand positions, status indicators, valid/unavailable heart rate, and awake/sleep transitions. The analog dial uses a 12-hour cycle for either device time-display setting.

The manifest targets only `fr55`. The watch face uses the system's `onUpdate` callback without custom timers or animations. In low-power mode, the system updates the watch face once per minute.

## Build and install on the watch

1. Connect the watch to your computer using a data cable.
2. Run **Monkey C: Build for Device**, select **Forerunner 55**, and choose `bin/` as the output directory.
3. Copy the generated `.prg` file to `GARMIN/APPS` on the watch when its storage is accessible from your computer.
4. Safely disconnect the watch. From the watch face, hold **UP**, open **Watch Face**, select **Daily55**, and apply it.

On macOS, access to the watch's storage depends on its connection mode. If the drive does not appear in Finder, check the USB connection and Garmin's instructions before copying the file.

If the SDK's `bin` directory is on your `PATH`, you can build from a terminal at the project root (adjust the key path to match its location):

```sh
mkdir -p bin
monkeyc -f monkey.jungle -d fr55 -y keys/developer_key.der -o bin/Daily55.prg -w
```

The SDK has not been added to `PATH` on this machine. You can use the current SDK directly:

```sh
GARMIN_SDK_DIR="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
mkdir -p bin
"$GARMIN_SDK_DIR/bin/monkeyc" -f monkey.jungle -d fr55 -y keys/developer_key.der -o bin/Daily55.prg -w
"$GARMIN_SDK_DIR/bin/connectiq"
# Run the following command after the simulator window opens:
"$GARMIN_SDK_DIR/bin/monkeydo" bin/Daily55.prg fr55
```

The `monkeydo` command keeps the connection open while the app runs; use another terminal if you need to build again. The current build is at `bin/Daily55.prg`.

## Files to edit

- `source/Daily55View.mc`: layout, colors, and displayed data.
- `source/Daily55App.mc`: application entry point.
- `source/Daily55Data.mc`: heart-rate validation and status value limits.
- `manifest.xml`: app ID, `watchface` type, target device, and minimum API level.
- `monkey.jungle`: source and resource paths.
- `resources/strings/strings.xml`: watch face name.
- `resources/drawables/`: application icon and generated radial background.
- `resources/fonts/`: generated bitmap fonts and resource definitions.
- `tools/GenerateAssets.java`: asset generator; edit this instead of generated images or font metrics.

## Assets and focused tests

Regenerate the background and bitmap fonts from the repository root with the installed JDK:

```sh
java -Djava.awt.headless=true tools/GenerateAssets.java
```

The generator uses the bundled [Barlow Condensed Regular](https://github.com/google/fonts/tree/main/ofl/barlowcondensed) font. Its original font and generated bitmap derivatives are covered by the [SIL Open Font License](tools/fonts/OFL.txt). No additional Java libraries are required.

Build and run the focused data tests in an open simulator (stop the running face first using **File > Kill App**):

```sh
GARMIN_SDK_DIR="$(cat "$HOME/Library/Application Support/Garmin/ConnectIQ/current-sdk.cfg")"
"$GARMIN_SDK_DIR/bin/monkeyc" -f tests/test.jungle -d fr55 -y keys/developer_key.der -o bin/Daily55-tests.prg -t -w
"$GARMIN_SDK_DIR/bin/monkeydo" bin/Daily55-tests.prg fr55 -t
```

The test jungle includes `tests/`; the regular build does not include test fixtures.

## Verification status

Checked on **5 November 2026**:

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
