module drawing;
import std.functional: toDelegate;
import events;
import network;
import info;
import help;

shared static this()
{
    subscribe!"render"(toDelegate(&renderNetwork));
    subscribe!"render"(toDelegate(&renderInfo));
    subscribe!"render"(toDelegate(&renderHelp));
}
