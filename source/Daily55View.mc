import Toybox.ActivityMonitor;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;
import Toybox.Time.Gregorian;
import Toybox.WatchUi;

class Daily55View extends WatchUi.WatchFace {
    var _layout;
    var _state;
    var _heartRate as Lang.Array<Lang.Number> or Null = null;
    var _lastHrRefresh = null;

    function initialize() {
        WatchFace.initialize();
        _layout = new Daily55Layout();
        _state = new Daily55State();
    }

    function onLayout(dc) {
        _layout.loadResources(dc);
    }

    function onShow() {
        _lastHrRefresh = null;
    }

    function onEnterSleep() {
        _state.sleeping = true;
        WatchUi.requestUpdate();
    }

    function onExitSleep() {
        _state.sleeping = false;
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

        var settings = System.getDeviceSettings();
        _state.update(timestamp, System.getClockTime(), Gregorian.info(now, Time.FORMAT_SHORT),
            settings.is24Hour, _heartRate, settings.notificationCount,
            settings.phoneConnected, System.getSystemStats().battery);
        _layout.render(dc, _state);
    }
}
