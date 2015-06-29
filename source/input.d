import derelict.sdl2.sdl;
import std.functional: toDelegate;
import std.c.stdlib: exit;
import std.string: format;
import std.conv: to;
import helpers;
import subscribed;
import impulse;
import sdl;
import textures;

private
{
    enum string messageBase = "Please enter a new voltage value:";
    short v0buffer = 0;
}

shared static this()
{
    subscribe("keyChange", toDelegate(&handleKeyEvent));
}

void handleKeyEvent(int key)
{
    switch (key)
    {
        //case SDLK_r: rebuildNetwork; break
        //case SDLK_v: startChangeVoltage; break;
        case SDLK_ESCAPE: exit(0); break;
        case SDLK_RETURN: endChangeVoltage; break;
        //case SDLK_SPACE: simulate;
        case SDLK_0, SDLK_1, SDLK_2, SDLK_3, SDLK_4, SDLK_5, SDLK_6, SDLK_7,
             SDLK_8, SDLK_9, SDLK_MINUS, SDLK_BACKSPACE:
                 numericInput(*SDL_GetKeyName(key));
                 break;

        default: break;
    }
}

void numericInput(char symbol)
{
    //if (!awaitingInput) {
    //    return;
    //}

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
    //redraw;
}

void startChangeVoltage()
{
    //awaitingInput = true;
    //text.renderMessage(messageBase);
    //redraw;
}

void endChangeVoltage()
{
//    if (awaitingInput) {
//        awaitingInput = false;
//        Impulse.defaultv0 = v0buffer;
//        v0buffer = 0;
//        rootImpulse.destroy;
//        rootImpulse = new Impulse(rootNeuron);
//    }

//    text.hideMessage;
    //redraw;
}
