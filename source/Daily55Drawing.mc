import Toybox.Graphics;

module Daily55Drawing {
    function drawStatus(dc, state, font) {
        dc.drawText(94, 49, font, state.notifications, Graphics.TEXT_JUSTIFY_RIGHT);
        drawBluetooth(dc, state.phoneConnected);
        drawBattery(dc, state.battery);
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
