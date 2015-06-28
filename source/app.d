import std.conv: to;
import std.string: format;
import std.typecons;
import helpers;
import sdl;
import impulse;
import neuron;

void main()
{
    while (true) {
        rebuild;
        redraw;
        enterEventLoop;
    }
}
