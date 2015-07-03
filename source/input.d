import Dgame.System.Keyboard;
import std.functional: toDelegate;
import std.c.stdlib: exit;
import std.string: format;
import std.conv: to;
import subscribed;
import impulse;
import neuron;

private
{
    alias Key = Keyboard.Key;
    bool awaitingInput;
    bool blockedInput;
    enum string messageBase = "Please enter a new voltage value:";
    short v0buffer = 0;
}

shared static this()
{
    subscribe("keyChange", toDelegate(&handleKeyEvent));
    subscribe("blockInput", toDelegate(&blockInput));
}

void handleKeyEvent(Key key)
{
    import derelict.sdl2.sdl: SDL_GetKeyName;

    switch (key)
    {
        case Key.R:
            resetInput;
            publish("rebuildNetwork");
            break;

        case Key.V:
            if (!blockedInput)
                startChangeVoltage;
            break;

        case Key.H:
            resetInput;
            publish("toggleHelp");
            publish("redraw");
            return;

        case Key.Escape:
            exit(0);
            break;

        case Key.Return:
            if (!blockedInput)
                endChangeVoltage;
            break;

        case Key.Space:
            if (!blockedInput)
            {
                resetInput;
                publish("_simulate");
            }
            return;

        case Key.Num0, Key.Num1, Key.Num2, Key.Num3, Key.Num4, Key.Num5,
             Key.Num6, Key.Num7, Key.Num8, Key.Num9, Key.Minus, Key.Backspace:
                 if (!blockedInput)
                     onInput(*SDL_GetKeyName(key));
                 break;

        default: return;
    }

    publish("hideHelp");
    publish("redraw");
}

void resetInput()
{
    if (!awaitingInput)
        return;

    publish("hideInfo");
    awaitingInput = false;
    v0buffer = 0;
}

void onInput(char symbol)
{
    if (!awaitingInput)
        return;

    if (symbol == '-')
        v0buffer = -v0buffer;

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

     publish("showInfo", "%s %dmv".format(messageBase, v0buffer));
     publish("redraw");
}

void startChangeVoltage()
{
    awaitingInput = true;
    publish("showInfo", messageBase);
    publish("redraw");
}

void endChangeVoltage()
{
    if (awaitingInput)
    {
        awaitingInput = false;
        Impulse.defaultv0 = v0buffer;
        v0buffer = 0;
        publish("rebuildImpulse");
    }

    publish("hideInfo");
    publish("redraw");
}

void blockInput(bool state)
{
    blockedInput = state;
}
