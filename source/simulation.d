import core.thread: Fiber, Thread, dur;
import std.functional;
import std.conv: to;
import neuron;
import point;
import sdl;
import helpers;
import impulse;

Fiber[] fibers;
Linscale!float scale;

void drawNeuron(Neuron neuron = Neuron.root)
{
    resetColor;
    drawLine(neuron.start, neuron.length, neuron.angle);
    drawDisk(neuron.end);

    foreach (subneuron; neuron.connected)
        drawNeuron(subneuron);
}

Fiber genFiber(Impulse impulse)
{
    void func()
    {
        simulateImpulse(impulse);
    }

    return new Fiber(&func);
}

void simulateImpulse(Impulse impulse)
{
    if (impulse.parent is null) {
        auto scaled = to!ubyte(scale(impulse.v0));

        setPurple(scaled);
        drawDisk(impulse.neuron.end);
        render;

        foreach (child; impulse.connected) {
            fibers ~= genFiber(child);
        }

        return;
    }

    auto neuron = impulse.neuron;

    foreach (int j, row; impulse.matrix) {
        auto start = neuron.start + Point.fromPolar(10, neuron.angle);
        auto length = (neuron.length - 20) / (seg - 1);
        auto step = Point.fromPolar(length, neuron.angle);

        foreach (int i, number; row) {
            auto scaled = to!ubyte(scale(number));
            setPurple(scaled);
            drawLine(start, length, neuron.angle);
            start += step;
        }

        render;
        Fiber.yield;
    }

    auto scaled = to!ubyte(scale(impulse.v0));

    setPurple(scaled);
    drawDisk(neuron.end);
    render;

    foreach (child; impulse.connected) {
        fibers ~= genFiber(child);
    }
}

void runSimulation()
{
    scale = linscale([0, Impulse.root.peak], [48f, 255f]);

    bool checkFibers()
    {
        foreach (fiber; fibers)
            if (fiber.state == Fiber.State.HOLD)
                return true;

        return false;
    }

    fibers ~= genFiber(Impulse.root);

    while (checkFibers) {
        foreach (fiber; fibers) {
            if (fiber.state == Fiber.State.HOLD) {
                fiber.call;
            }
        }

        Thread.sleep(dur!"msecs"(25));
    }
}
