import Toybox.ActivityMonitor;
import Toybox.Graphics;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

// Layout for the Forerunner 55's 208 x 208 round display.
class Daily55View extends WatchUi.WatchFace {
    function initialize() {
        WatchFace.initialize();
    }

    function onUpdate(dc) {
        var centerX = dc.getWidth() / 2;
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.clear();

        var clock = System.getClockTime();
        var hour = clock.hour;
        var period = "";
        if (!System.getDeviceSettings().is24Hour) {
            period = hour >= 12 ? "PM" : "AM";
            hour = hour % 12;
            if (hour == 0) {
                hour = 12;
            }
        }
        var timeText = hour.format("%02d") + ":" + clock.min.format("%02d");

        var date = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
        var weekdays = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];
        var dateText = weekdays[date.day_of_week - 1] + " " +
            date.day.format("%02d") + "/" + date.month.format("%02d");

        dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
        dc.drawText(centerX, 24, Graphics.FONT_SMALL, dateText, Graphics.TEXT_JUSTIFY_CENTER);

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        var timeFont = Graphics.FONT_NUMBER_HOT;
        if (dc.getTextWidthInPixels(timeText, timeFont) > 184) {
            timeFont = Graphics.FONT_NUMBER_MEDIUM;
        }
        // Center vertically so changing the time font does not shift the layout.
        var timeY = 89 - dc.getFontHeight(timeFont) / 2;
        dc.drawText(centerX, timeY, timeFont, timeText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, 116, Graphics.FONT_XTINY, period, Graphics.TEXT_JUSTIFY_CENTER);

        var battery = System.getSystemStats().battery.toNumber();
        dc.drawText(centerX, 139, Graphics.FONT_XTINY,
            "BAT " + battery.format("%d") + "%", Graphics.TEXT_JUSTIFY_CENTER);

        var activity = ActivityMonitor.getInfo();
        var steps = activity.steps;
        var stepsText = "--";
        if (steps != null) {
            stepsText = steps.format("%d");
        }
        dc.drawText(centerX, 162, Graphics.FONT_XTINY,
            "STEPS " + stepsText, Graphics.TEXT_JUSTIFY_CENTER);

        // The bar is hidden when daily activity data or its goal is unavailable.
        var goal = activity.stepGoal;
        if (steps != null && goal != null && goal > 0) {
            var progress = steps.toFloat() / goal;
            if (progress > 1.0) {
                progress = 1.0;
            }
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawRectangle(centerX - 40, 188, 80, 4);
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_BLACK);
            dc.fillRectangle(centerX - 39, 189, (78 * progress).toNumber(), 2);
        }
    }
}
