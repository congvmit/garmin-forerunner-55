import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;

(:test)
class HeartRateFixture {
    var heartRate;
    var when;
    function initialize(value, timestamp) {
        heartRate = value;
        when = timestamp == null ? null : new Time.Moment(timestamp);
    }
}

(:test)
class HeartRateFixtures {
    var _samples as Lang.Array<HeartRateFixture>;
    var _index = 0;
    function initialize(samples as Lang.Array<HeartRateFixture>) {
        _samples = samples;
    }
    function next() {
        if (_index >= _samples.size()) {
            return null;
        }
        var sample = _samples[_index];
        _index += 1;
        return sample;
    }
}

(:test)
function skipsInvalidHeartRates(logger as Test.Logger) as Boolean {
    var samples = new HeartRateFixtures([
        new HeartRateFixture(255, 1000),
        new HeartRateFixture(null, 999),
        new HeartRateFixture(0, 998),
        new HeartRateFixture(72, 997),
        new HeartRateFixture(65, 996)
    ]);
    var result = Daily55Data.latestHeartRate(samples, 1000) as Lang.Array<Lang.Number>;
    Test.assertEqual(result[0], 72);
    return true;
}

(:test)
function missingAndExpiredHeartRates(logger as Test.Logger) as Boolean {
    Test.assert(Daily55Data.latestHeartRate(new HeartRateFixtures([]), 1000) == null);
    var samples = new HeartRateFixtures([
        new HeartRateFixture(72, 699),
        new HeartRateFixture(80, null),
        new HeartRateFixture(-1, 999)
    ]);
    Test.assert(Daily55Data.latestHeartRate(samples, 1000) == null);
    return true;
}

(:test)
function heartRateFreshnessBoundary(logger as Test.Logger) as Boolean {
    var samples = new HeartRateFixtures([
        new HeartRateFixture(90, 1001),
        new HeartRateFixture(72, 700)
    ]);
    var result = Daily55Data.latestHeartRate(samples, 1000) as Lang.Array<Lang.Number>;
    Test.assertEqual(result[0], 72);
    Test.assertEqual(result[1], 700);
    return true;
}

(:test)
function statusLimits(logger as Test.Logger) as Boolean {
    Test.assertEqual(Daily55Data.notificationText(0), "0");
    Test.assertEqual(Daily55Data.notificationText(99), "99");
    Test.assertEqual(Daily55Data.notificationText(100), "99+");
    Test.assertEqual(Daily55Data.notificationText(-1), "0");
    Test.assertEqual(Daily55Data.batteryPercent(-1), 0);
    Test.assertEqual(Daily55Data.batteryPercent(0), 0);
    Test.assertEqual(Daily55Data.batteryPercent(50.5), 50);
    Test.assertEqual(Daily55Data.batteryPercent(100), 100);
    Test.assertEqual(Daily55Data.batteryPercent(101), 100);
    return true;
}
