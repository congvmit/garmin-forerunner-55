import Toybox.ActivityMonitor;
import Toybox.Lang;

module Daily55Data {
    // The iterator is newest first. Skip invalid samples rather than showing a
    // fabricated reading or retaining a value after the watch is taken off.
    function latestHeartRate(iterator, now) as Lang.Array<Lang.Number> or Null {
        var sample = iterator.next();
        while (sample != null) {
            if (sample.when != null && sample.heartRate != null) {
                var timestamp = sample.when.value();
                var value = sample.heartRate;
                if (timestamp <= now && now - timestamp <= 300 &&
                    value > 0 && value != ActivityMonitor.INVALID_HR_SAMPLE) {
                    return [value, timestamp];
                }
            }
            sample = iterator.next();
        }
        return null;
    }

    function notificationText(count) {
        if (count > 99) {
            return "99+";
        }
        return count < 0 ? "0" : count.format("%d");
    }

    function batteryPercent(value) {
        if (value < 0) {
            return 0;
        }
        return value > 100 ? 100 : value.toNumber();
    }
}
