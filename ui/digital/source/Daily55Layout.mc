import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;

// Same contract as the analog layout, selected exclusively by the Jungle file.
class Daily55Layout {
    const ACCENT = 0x00FFFF;
    var _smallFont;
    var _valueFont;
    var _timeFont;
    var _timeY;

    function initialize() {
    }

    function loadResources(dc) {
        if (_smallFont != null) {
            return;
        }
        _smallFont = WatchUi.loadResource(Rez.Fonts.Condensed12);
        _valueFont = WatchUi.loadResource(Rez.Fonts.Condensed20);

        // Measure components once, avoiding 1,440 formatted strings per font.
        var fonts = [Graphics.FONT_NUMBER_HOT, Graphics.FONT_NUMBER_MEDIUM, Graphics.FONT_NUMBER_MILD];
        for (var i = 0; i < fonts.size(); i += 1) {
            var font = fonts[i];
            var height = dc.getFontHeight(font);
            var maxWidth = widestPair(dc, font, 24) + widestPair(dc, font, 60)
                + dc.getTextWidthInPixels(":", font);
            // Native number fonts include substantial leading in their line height.
            // Fit the complete line box inside the dial with a four-pixel margin.
            var halfHeight = height / 2.0 + 7;
            var available = 2 * Math.sqrt(100 * 100 - halfHeight * halfHeight);
            if (height <= 90 && maxWidth <= available) {
                _timeFont = font;
                _timeY = 110 - height / 2;
                break;
            }
        }
        // The native text font guarantees a readable fallback if numeric fonts change.
        if (_timeFont == null) {
            _timeFont = Graphics.FONT_LARGE;
            _timeY = 110 - dc.getFontHeight(_timeFont) / 2;
        }
    }

    function widestPair(dc, font, limit) {
        var width = 0;
        for (var value = 0; value < limit; value += 1) {
            var measured = dc.getTextWidthInPixels(value.format("%02d"), font);
            if (measured > width) {
                width = measured;
            }
        }
        return width;
    }

    function render(dc, state) {
        dc.setColor(ACCENT, Graphics.COLOR_BLACK);
        dc.clear();
        Daily55Drawing.drawStatus(dc, state, _smallFont);
        dc.drawText(104, 65, _smallFont, state.dateText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(104, _timeY, _timeFont,
            Daily55Time.clockText(state.clock.hour, state.clock.min, state.is24Hour), Graphics.TEXT_JUSTIFY_CENTER);

        dc.drawText(104, 146, _smallFont,
            Daily55Time.periodText(state.clock.hour, state.is24Hour), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(104, 164, _valueFont, state.heartRateText + " bpm", Graphics.TEXT_JUSTIFY_CENTER);
        if (!state.sleeping) {
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            dc.drawText(104, 187, _smallFont, state.clock.sec.format("%02d"), Graphics.TEXT_JUSTIFY_CENTER);
        }
    }
}
