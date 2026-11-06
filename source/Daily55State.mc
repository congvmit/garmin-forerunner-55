import Toybox.Lang;

// Updated in place by the controller; layouts only read this snapshot.
class Daily55State {
    var timestamp = 0;
    var clock;
    var date;
    var is24Hour = true;
    var sleeping = false;
    var heartRate = null;
    var heartRateText = "--";
    var notifications = "0";
    var phoneConnected = false;
    var battery = 0;
    var dateText = "";
    var _weekdays as Lang.Array<Lang.String> = ["SUN", "MON", "TUE", "WED", "THU", "FRI", "SAT"];

    function initialize() {
    }

    function update(now, clockTime, calendarDate, use24Hour, sample as Lang.Array<Lang.Number> or Null,
                    notificationCount, connected, batteryValue) {
        timestamp = now;
        clock = clockTime;
        date = calendarDate;
        is24Hour = use24Hour;
        heartRate = null;
        heartRateText = "--";
        if (sample != null && now >= sample[1] && now - sample[1] <= 300) {
            heartRate = sample[0];
            heartRateText = heartRate.format("%d");
        }
        notifications = Daily55Data.notificationText(notificationCount);
        phoneConnected = connected;
        battery = Daily55Data.batteryPercent(batteryValue);
        dateText = _weekdays[date.day_of_week - 1] + " " + date.day.format("%d");
    }
}
