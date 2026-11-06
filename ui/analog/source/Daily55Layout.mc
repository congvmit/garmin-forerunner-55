import Toybox.Graphics;
import Toybox.Math;
import Toybox.WatchUi;

// Exactly one UI supplies this class in each build.
class Daily55Layout {
    const ACCENT = 0x00FFFF;
    var _background;
    var _smallFont;
    var _valueFont;

    function initialize() {
    }

    function loadResources(dc) {
        if (_background == null) {
            _background = WatchUi.loadResource(Rez.Drawables.RadialDots);
            _smallFont = WatchUi.loadResource(Rez.Fonts.Condensed12);
            _valueFont = WatchUi.loadResource(Rez.Fonts.Condensed20);
        }
    }

    function render(dc, state) {
        dc.setColor(ACCENT, Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawBitmap(0, 0, _background);
        var clock = state.clock;
        if (!state.sleeping) {
            drawSeconds(dc, clock.sec);
        }

        // Backing plates keep the small fields separate from the radial texture.
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.fillRectangle(68, 48, 73, 18);
        dc.fillRectangle(75, 68, 58, 17);
        dc.fillRectangle(61, 118, 86, 39);
        dc.setColor(ACCENT, Graphics.COLOR_BLACK);

        Daily55Drawing.drawStatus(dc, state, _smallFont);
        dc.drawText(104, 69, _smallFont, state.dateText, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(104, 119, _smallFont, "HR", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(104, 132, _valueFont, state.heartRateText + " bpm", Graphics.TEXT_JUSTIFY_CENTER);

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
}
