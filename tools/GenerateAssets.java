import java.awt.Color;
import java.awt.Font;
import java.awt.Graphics2D;
import java.awt.RenderingHints;
import java.awt.font.GlyphVector;
import java.awt.image.BufferedImage;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Locale;
import javax.imageio.ImageIO;

// Run from the project root: java -Djava.awt.headless=true tools/GenerateAssets.java
class GenerateAssets {
    public static void main(String[] args) throws Exception {
        Font source = Font.createFont(Font.TRUETYPE_FONT,
            Path.of("tools/fonts/BarlowCondensed-Regular.ttf").toFile());
        Files.createDirectories(Path.of("resources/fonts"));
        for (int size : new int[] {12, 20}) {
            makeFont(source.deriveFont((float) size), size);
        }
        BufferedImage dial = new BufferedImage(208, 208, BufferedImage.TYPE_INT_RGB);
        Graphics2D graphics = dial.createGraphics();
        graphics.setColor(Color.BLACK);
        graphics.fillRect(0, 0, 208, 208);
        graphics.setColor(Color.CYAN);
        for (int spoke = 0; spoke < 60; spoke++) {
            double angle = Math.toRadians(spoke * 6);
            for (int radius = 50; radius <= 100; radius += 5) {
                // Small, sparse dots at either end give a fade using only two colors.
                if ((radius <= 55 || radius >= 95) && spoke % 2 != 0) {
                    continue;
                }
                int diameter = radius >= 65 && radius <= 85 ? 2 : 1;
                int x = (int) Math.round(104 + Math.sin(angle) * radius);
                int y = (int) Math.round(104 - Math.cos(angle) * radius);
                graphics.fillRect(x - diameter / 2, y - diameter / 2, diameter, diameter);
            }
        }
        graphics.dispose();
        Path output = Path.of("ui/analog/resources/drawables/radial_dots.png");
        Files.createDirectories(output.getParent());
        ImageIO.write(dial, "png", output.toFile());
        System.out.println("Generated 208x208 radial background and 12/20 px bitmap fonts.");
    }

    private static void makeFont(Font font, int size) throws Exception {
        int cell = 32;
        int columns = 16;
        BufferedImage atlas = new BufferedImage(columns * cell, 6 * cell, BufferedImage.TYPE_INT_ARGB);
        Graphics2D graphics = atlas.createGraphics();
        graphics.setRenderingHint(RenderingHints.KEY_TEXT_ANTIALIASING, RenderingHints.VALUE_TEXT_ANTIALIAS_OFF);
        graphics.setRenderingHint(RenderingHints.KEY_FRACTIONALMETRICS, RenderingHints.VALUE_FRACTIONALMETRICS_OFF);
        graphics.setFont(font);
        graphics.setColor(Color.WHITE);
        String name = "barlow" + size;
        StringBuilder chars = new StringBuilder();
        for (int code = 32; code <= 126; code++) {
            String character = Character.toString((char) code);
            GlyphVector glyph = font.createGlyphVector(graphics.getFontRenderContext(), character);
            var bounds = glyph.getPixelBounds(graphics.getFontRenderContext(), 0, 0);
            int x = ((code - 32) % columns) * cell;
            int y = ((code - 32) / columns) * cell;
            graphics.drawString(character, x - bounds.x, y - bounds.y);
            chars.append(String.format(Locale.ROOT,
                "char id=%d x=%d y=%d width=%d height=%d xoffset=%d yoffset=%d xadvance=%d page=0 chnl=15%n",
                code, x, y, bounds.width, bounds.height, bounds.x,
                size + bounds.y, graphics.getFontMetrics().charWidth((char) code)));
        }
        graphics.dispose();
        String header = "info face=\"Barlow Condensed\" size=" + size + " bold=0 italic=0 unicode=1 smooth=0 aa=1\n"
            + "common lineHeight=" + (size + 2) + " base=" + size + " scaleW=512 scaleH=192 pages=1 packed=0\n"
            + "page id=0 file=\"" + name + ".png\"\nchars count=95\n";
        Files.writeString(Path.of("resources/fonts/" + name + ".fnt"), header + chars);
        ImageIO.write(atlas, "png", Path.of("resources/fonts/" + name + ".png").toFile());
    }
}
