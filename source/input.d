import derelict.sdl2.sdl;
import std.string: format;
import std.conv: to;
import helpers;
import global;
import impulse;
import sdl;
import textures;

private
{
    enum string messageBase = "Please enter a new voltage value:";
    short v0buffer = 0;
}

void numericInput()
{
    char symbol = *SDL_GetKeyName(lastEvent.key.keysym.sym);

    if (!awaitingInput) {
        return;
    }

    if (symbol == '-')
    {
        v0buffer = -v0buffer;
    }

    else
    {
        auto str = to!string(v0buffer);

        try {
            if (symbol == 'B')
                v0buffer = str.length > 1 ? to!short(str[0..$ - 1]) : 0;
            else
                v0buffer = to!short(str ~ symbol);
        }

        catch (Exception e) {}
    }

    legend.render;
    text.renderMessage("%s %d".format(messageBase, v0buffer));
    redraw;
}

void startChangeVoltage()
{
    awaitingInput = true;
    text.renderMessage(messageBase);
    redraw;
}

void endChangeVoltage()
{
    if (awaitingInput) {
        awaitingInput = false;
        Impulse.defaultv0 = v0buffer;
        v0buffer = 0;
        rootImpulse.destroy;
        rootImpulse = new Impulse(rootNeuron);
    }

    text.hideMessage;
    redraw;
}
