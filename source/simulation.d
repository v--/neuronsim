module simulation;
import Dgame.System;
import Dgame.Window: Window;
import Dgame.Graphic;
import Dgame.Math;
import core.thread: Thread, dur;
import std.algorithm: reverse;
import std.typecons: scoped;
import std.conv: to;
import subscribed.event;
import subscribed.pubsub;
import helpers;
import impulse;
import neuron;

private VoidEvent event;
alias delegType = void delegate(Impulse, int);

shared static this()
{
    subscribe("simulate", toDelegate(&simulate));
    subscribe("prerender", toDelegate(&cancelSimulation));
    event = new VoidEvent;
}

void cancelSimulation(Window* window, Font* font)
{
    while (event.subscribers.length)
        event.pop;
}

void addToEvent(delegType func, Impulse impulse, int rowNumber)
{
    void next()
    {
        func(impulse, rowNumber);
    }

    event ~= &next;
}

void simulate(Window* window, Font* font)
{
    auto pointScale = genPointScale(window);

    auto redScale = genLinscale!(float, ubyte)(
        0, Impulse.root.v0,
        255, 50
    );

    void pause()
    {
        publish("handleEvent");
        window.display;
        StopWatch.wait(10);
        publish("handleEvent");
    }

    void simulateRow(Impulse impulse, int rowNumber)
    {
        if (event.subscribers.length)
            event.shift;

        auto greenScale = genLinscale!(float, ubyte)(
            0, impulse.v0,
            255, 50
        );

        auto neuron = impulse.neuron;
        auto row = impulse.matrix[rowNumber];
        auto rowLength = cast(float)row.length;

        auto start = pointScale(neuron.start);
        auto step = neuron.point(1 / rowLength).pointScale -
                    fromPolar(20, neuron.angle) / rowLength - start;

        window.drawCircle(
            start,
            Color4b(redScale(row[0]), greenScale(row[0]), 200)
        );

        start += fromPolar(10, neuron.angle);

        foreach (int i, number; row)
        {
            auto end = start + step;
            window.drawLine(
                start, end,
                Color4b(redScale(number), greenScale(number), 200)
            );
            start = end;
        }

        window.drawCircle(
            pointScale(neuron.end),
            Color4b(redScale(row[$ - 1]), greenScale(row[$ - 1]), 200)
        );

        pause;

        if (rowNumber + 1 < impulse.matrix.length)
            addToEvent(&simulateRow, impulse, rowNumber + 1);
        else
            foreach (child; impulse.connected)
                addToEvent(&simulateRow, child, 0);
    }

    foreach (child; Impulse.root.connected)
        addToEvent(&simulateRow, child, 0);

    while (event.subscribers.length)
        event();
}
