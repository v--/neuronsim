module simulation;
import Dgame.System;
import Dgame.Window: Window;
import Dgame.Graphic;
import Dgame.Math;
import std.string: format;
import subscribed.event;
import events;
import helpers;
import impulse;
import neuron;
import network;

private
{
    Event!(void delegate()) event;
    alias delegType = void delegate(Impulse, int, int, int);
    enum basePause = 30;
    bool simulating;
}

void cancelSimulation()
{
    simulating = false;
    event.clear;
}

void addToEvent(delegType func, Impulse impulse, int rowNumber, int childNumber, int level)
{
    void next()
    {
        return func(impulse, rowNumber, childNumber, level);
    }

    event ~= &next;
}

void simulate(Window* window, Font* font)
{
    publish!"redraw";

    renderNetwork(window, font);
    event.clear;
    simulating = true;
    auto pointScale = genPointScale(window);
    float[] result;

    void showText(string msg)
    {
        publish!"showInfo"(msg);
        publish!"renderInfo"(window, font);
        window.display;
    }

    void pause(float level)
    {
        import std.math: pow, ceil;
        import std.conv: to;
        auto time = level == 0 ? basePause : pow(basePause, 1 / (1.5 * level)).ceil.to!int;
        publish!"handleEvent";
        window.display;
        StopWatch.wait(time);
        publish!"handleEvent";
    }

    void simulateRow(Impulse impulse, int rowNumber, int childNumber, int level)
    {
        event.shift;

        if (!simulating)
            return;

        auto neuron = impulse.neuron;
        auto row = impulse.matrix[rowNumber];
        auto rowLength = cast(float)row.length;

        auto start = pointScale(neuron.start);
        auto step = neuron.point(1 / rowLength).pointScale -
                    fromPolar(20, neuron.angle) / rowLength - start;

        if (childNumber == 0)
            window.drawCircle(start, impulse.getColor(row[0]));

        start += fromPolar(10, neuron.angle);

        foreach (int i, number; row)
        {
            auto end = start + step;
            window.drawLine(
                start, end,
                impulse.getColor(number)
            );
            start = end;
        }

        window.drawCircle(
            pointScale(neuron.end),
            impulse.getColor(row[$ - 1])
        );

        pause(level);

        if (!simulating)
            return;

        if (rowNumber + 1 < impulse.matrix.length)
        {
            addToEvent(&simulateRow, impulse, rowNumber + 1, childNumber, level);
        }

        else if (impulse.connected.length)
        {
            foreach (int i, child; impulse.connected)
                addToEvent(&simulateRow, child, 0, i, level + 1);
        }

        else
        {
            result ~= impulse.endVoltage;
            showText("%d impulses have reached the end".format(result.length));
        }
    }

    foreach (int i, child; Impulse.root.connected)
        addToEvent(&simulateRow, child, 0, i, 0);

    while (!event.empty)
        event();

    if (!simulating)
        return;

    auto abcScale = genLinscale(result.extent.min, result.extent.max, 1, 9);
    string message;

    foreach (f; result)
        message ~= abcScale(f) + 48;

    debug writeln(message);
    publish!"showInfo"(message);
    publish!"redraw";

    simulating = false;
}

shared static this()
{
    subscribe!"simulate"(&simulate);
    subscribe!"cancelSimulation"(&cancelSimulation);
}
