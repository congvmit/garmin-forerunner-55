import Toybox.Lang;
import Toybox.Test;
import Toybox.Time;
import Toybox.Time.Gregorian;

(:test)
function snapshotExpiresCachedHeartRate(logger as Test.Logger) as Boolean {
    var state = new Daily55State();
    var date = Gregorian.info(new Time.Moment(1000), Time.FORMAT_SHORT);
    state.sleeping = true;
    state.update(1000, null, date, false, [72, 700], 100, false, 101);
    Test.assertEqual(state.heartRateText, "72");
    Test.assertEqual(state.notifications, "99+");
    Test.assertEqual(state.battery, 100);
    Test.assertEqual(state.is24Hour, false);
    Test.assertEqual(state.sleeping, true);

    state.update(1001, null, date, true, [72, 700], 0, true, -1);
    Test.assert(state.heartRate == null);
    Test.assertEqual(state.heartRateText, "--");
    Test.assertEqual(state.battery, 0);
    Test.assertEqual(state.phoneConnected, true);
    state.update(699, null, date, true, [72, 700], 0, true, 50);
    Test.assertEqual(state.heartRateText, "--");
    state.update(1000, null, date, true, null, 0, true, 50);
    Test.assertEqual(state.heartRateText, "--");
    return true;
}
