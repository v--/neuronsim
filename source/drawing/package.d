module drawing;
import std.functional: toDelegate;
import subscribed.pubsub;
import network;
import info;
import help;

shared static this()
{
    subscribe("render", toDelegate(&renderNetwork));
    subscribe("render", toDelegate(&renderInfo));
    subscribe("render", toDelegate(&renderHelp));
}
