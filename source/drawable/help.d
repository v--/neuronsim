module help;
import Dgame.System;
import Dgame.Window;
import Dgame.Graphic;
import Dgame.Math;
import std.typecons: scoped;
import std.functional: toDelegate;
import subscribed.pubsub;
import helpers;

private
{
    bool state;

    static enum help = [
        "Esc":         "Quit",
        "Space":       "Launch an impulse simulation",
        "Backspace":   "Delete numbers while editing the initial voltage",
        "Minus":       "Change the sign of the voltage while editing it",
        "Return":      "Accept new initial voltage",
        "V":           "Change initial voltage, then any number to type",
        "R":           "Generate another network",
        "H":           "Display this help, then any key to hide it"
    ];
}

shared static this()
{
    subscribe("toggleHelp", toDelegate(&toggleHelp));
    subscribe("hideHelp", toDelegate(&hideHelp));
}

void renderHelp(Window* window, Font* font)
{
    auto text = scoped!Text(*font, "Press 'H' for help");
    text.setPosition(50, 50);
    refineText(text);
    window.draw(text);

    if (!state)
        return;

    drawBlocker(window, font);
    const size = window.getSize;
    const offsetLeft = size.width / 2 - 200;
    auto offsetTop = size.height / 2 - 150;

    foreach (keyStr, labelStr; help)
    {
        auto key = new Text(*font, keyStr);
        auto label = new Text(*font, labelStr);
        key.setPosition(offsetLeft, offsetTop);
        label.setPosition(offsetLeft + 120, offsetTop);
        offsetTop += 30;
        refineText(key); refineText(label);
        label.foreground = Color4b.Gray;
        window.draw(key); window.draw(label);
        key.destroy; label.destroy;
    }
}

void drawBlocker(Window* window, Font* font)
{
    auto size = window.getSize;

    auto blocker = scoped!Shape(Geometry.Quads,
        [
            Vertex(0, 0),
            Vertex(size.width, 0),
            Vertex(size.width, size.height),
            Vertex(0, size.height)
        ]
    );

    blocker.setColor(Color4b.Black.withTransparency(230));
    window.draw(blocker);
}

void toggleHelp()
{
    state ^= true;
}

void hideHelp()
{
    state = false;
}
