import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.Math;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class Daily55View extends WatchUi.WatchFace {
    const ACCENT = 0x00FFFF;
    var _background;
    var _smallFont;
    var _valueFont;
    var _sleeping = false;
    var _heartRate as Lang.Array<Lang.Number> or Null = null;
    var _lastHrRefresh = null;
    var _weekdays as Lang.Array<Lang.String> = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    function initialize() {
        WatchFace.initialize();
    }

    function onLayout(dc) {
        if (_background == null) {
            _background = WatchUi.loadResource(Rez.Drawables.RadialDots);
            _smallFont = WatchUi.loadResource(Rez.Fonts.Condensed12);
            _valueFont = WatchUi.loadResource(Rez.Fonts.Condensed20);
        }
    }

    function onShow() {
        _lastHrRefresh = null;
    }

    function onEnterSleep() {
        _sleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _sleeping = false;
        _lastHrRefresh = null;
        WatchUi.requestUpdate();
    }

    function onUpdate(dc) {
        var now = Time.now();
        var timestamp = now.value();
        if (_lastHrRefresh == null || timestamp < _lastHrRefresh || timestamp - _lastHrRefresh >= 60) {
            var iterator = ActivityMonitor.getHeartRateHistory(new Time.Duration(300), true);
            _heartRate = Daily55Data.latestHeartRate(iterator, timestamp);
            _lastHrRefresh = timestamp;
        }

        dc.setColor(ACCENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawBitmap(0, 0, _background);
        var clock = System.getClockTime();
        if (!_sleeping) {
            drawSeconds(dc, clock.sec);
        }

        // Backing plates keep the small fields separate from the radial texture.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(68, 48, 73, 18);
        dc.fillRectangle(75, 68, 58, 17);
        dc.fillRectangle(61, 118, 86, 39);
        dc.setColor(ACCENT, Graphics.COLOR_BLACK);

        var settings = System.getDeviceSettings();
        dc.drawText(94, 49, _smallFont, Daily55Data.notificationText(settings.notificationCount), Graphics.TEXT_JUSTIFY_RIGHT);
        drawBluetooth(dc, settings.phoneConnected);
        drawBattery(dc, Daily55Data.batteryPercent(System.getSystemStats().battery));

        var date = Gregorian.info(now, Time.FORMAT_SHORT);
        dc.drawText(104, 69, _smallFont,
            _weekdays[date.day_of_week - 1] + " " + date.day.format("%d"), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(104, 119, _smallFont, "HR", Graphics.TEXT_JUSTIFY_CENTER);
        var value = "--";
        if (_heartRate != null && timestamp >= _heartRate[1] && timestamp - _heartRate[1] <= 300) {
            value = _heartRate[0].format("%d");
        }
        dc.drawText(104, 132, _valueFont, value + " bpm", Graphics.TEXT_JUSTIFY_CENTER);

        // Hands always sit above data fields; their detached roots leave a center gap.
        drawHand(dc, (clock.hour % 12) * 30.0 + clock.min * 0.5, 68);
        drawHand(dc, clock.min * 6.0, 84);
    }

    function drawHand(dc, degrees, length) {
        var angle = degrees * Math.PI / 180.0;
        var sine = Math.sin(angle);
        var cosine = Math.cos(angle);
        var x1 = (104 + sine * 7).toNumber();
        var y1 = (104 - cosine * 7).toNumber();
        var x2 = (104 + sine * length).toNumber();
        var y2 = (104 - cosine * length).toNumber();
        dc.setColor(ACCENT, Graphics.COLOR_BLACK);
        dc.setPenWidth(5);
        dc.drawLine(x1, y1, x2, y2);
        dc.setPenWidth(1);
        dc.fillCircle(x1, y1, 2);
        dc.fillCircle(x2, y2, 2);
    }

    function drawSeconds(dc, seconds) {
        var angle = seconds * Math.PI / 30.0;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        for (var radius = 50; radius <= 100; radius += 5) {
            if ((radius <= 55 || radius >= 95) && seconds % 2 != 0) {
                continue;
            }
            var x = (104 + Math.sin(angle) * radius + 0.5).toNumber();
            var y = (104 - Math.cos(angle) * radius + 0.5).toNumber();
            if (radius >= 65 && radius <= 85) {
                dc.fillRectangle(x - 1, y - 1, 2, 2);
            } else {
                dc.fillRectangle(x, y, 1, 1);
            }
        }
    }

    function drawBluetooth(dc, connected) {
        dc.drawLine(102, 49, 102, 62);
        dc.drawLine(102, 49, 108, 54);
        dc.drawLine(108, 54, 97, 61);
        dc.drawLine(97, 50, 108, 57);
        dc.drawLine(108, 57, 102, 62);
        if (!connected) {
            dc.drawLine(96, 62, 109, 49);
        }
    }

    function drawBattery(dc, percentage) {
        dc.drawRoundedRectangle(115, 51, 17, 10, 2);
        dc.fillRectangle(132, 54, 2, 4);
        var width = (13 * percentage / 100.0).toNumber();
        if (width > 0) {
            dc.fillRectangle(117, 53, width, 6);
        }
    }
}
