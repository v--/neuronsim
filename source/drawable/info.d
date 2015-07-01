module info;
import Dgame.System;
import Dgame.Window;
import Dgame.Graphic;
import Dgame.Math;
import std.functional: toDelegate;
import std.typecons: scoped;
import subscribed.pubsub;
import helpers;

private string message;

shared static this()
{
    subscribe("showInfo", toDelegate(&showInfo));
    subscribe("hideInfo", toDelegate(&hideInfo));
}

void renderInfo(Window* window, Font* font)
{
    if (!message.length)
        return;

    auto text = scoped!Text(*font, message);
    text.setPosition(50, window.getSize.height - 70);
    refineText(text);
    window.draw(text);
}

void showInfo(string msg)
{
    message = msg;
}

void hideInfo()
{
    message = "";
}
