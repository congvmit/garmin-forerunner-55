import Toybox.Lang;
import Toybox.Test;

(:test)
function digitalMidnightAndNoon(logger as Test.Logger) as Boolean {
    Test.assertEqual(Daily55Time.clockText(0, 0, true), "00:00");
    Test.assertEqual(Daily55Time.clockText(0, 0, false), "12:00");
    Test.assertEqual(Daily55Time.periodText(0, false), "AM");
    Test.assertEqual(Daily55Time.clockText(12, 0, true), "12:00");
    Test.assertEqual(Daily55Time.clockText(12, 0, false), "12:00");
    Test.assertEqual(Daily55Time.periodText(12, false), "PM");
    return true;
}

(:test)
function digitalAfternoonAndLeadingZeros(logger as Test.Logger) as Boolean {
    Test.assertEqual(Daily55Time.clockText(13, 5, true), "13:05");
    Test.assertEqual(Daily55Time.clockText(13, 5, false), "01:05");
    Test.assertEqual(Daily55Time.periodText(13, false), "PM");
    Test.assertEqual(Daily55Time.clockText(9, 7, true), "09:07");
    Test.assertEqual(Daily55Time.clockText(9, 7, false), "09:07");
    Test.assertEqual(Daily55Time.periodText(9, false), "AM");
    Test.assertEqual(Daily55Time.clockText(23, 59, true), "23:59");
    Test.assertEqual(Daily55Time.clockText(23, 59, false), "11:59");
    Test.assertEqual(Daily55Time.periodText(23, true), "");
    return true;
}
