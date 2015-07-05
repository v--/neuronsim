module info;
import Dgame.System;
import Dgame.Window;
import Dgame.Graphic;
import Dgame.Math;
import std.typecons: scoped;
import events;
import helpers;

private string message;

void renderInfo(Window* window, Font* font)
{
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

shared static this()
{
    subscribe!"renderInfo"(&renderInfo);
    subscribe!"showInfo"(&showInfo);
    subscribe!"hideInfo"(&hideInfo);
}
