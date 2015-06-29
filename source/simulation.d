import core.thread: Fiber, Thread, dur;
import std.algorithm: find;
import std.container;
import std.conv: to;
import textures;
import helpers;
import impulse;
import global;
import neuron;
import vector;
import sdl;

private
{
    Linscale!float scale;
    DList!Fiber fibers;

    Fiber genFiber(Impulse impulse)
    {
        void func()
        {
            simulateImpulse(impulse);
        }

        return new Fiber(&func);
    }
}

void drawNeuron(Neuron neuron = rootNeuron)
{
    network.resetColor;
    network.drawLine(neuron.start, neuron.length, neuron.angle);
    network.drawDisk(neuron.end);

    foreach (subneuron; neuron.connected)
        drawNeuron(subneuron);
}

void simulateImpulse(Impulse impulse)
{
    if (impulse.parent is null) {
        auto scaled = to!ubyte(scale(impulse.v0));

        network.setPurple(scaled);
        network.drawDisk(impulse.neuron.end);
        Fiber.yield;

        foreach (child; impulse.connected) {
            fibers ~= genFiber(child);
        }

        return;
    }

    auto neuron = impulse.neuron;

    foreach (int j, row; impulse.matrix) {
        auto start = neuron.start + Vector.fromPolar(10, neuron.angle);
        auto length = (neuron.params.xTotal * sizeY / 5 - 20) / (seg - 1);
        auto step = Vector.fromPolar(length, neuron.angle);

        foreach (int i, number; row) {
            auto scaled = to!ubyte(scale(number));
            //setnetwork.Purple(scaled);
            network.setPurple(255);
            network.drawLine(start, length, neuron.angle);
            start += step;
        }

        Fiber.yield;
    }

    auto scaled = to!ubyte(scale(impulse.v0));

    network.setPurple(scaled);
    network.drawDisk(neuron.end);
    redraw;

    foreach (child; impulse.connected) {
        fibers ~= genFiber(child);
    }
}

void runSimulation()
{
    scale = linscale([0, rootImpulse.peak], [48f, 255f]);
    fibers ~= genFiber(rootImpulse);

    while (true) {
        auto terminated = find!(f => f.state != Fiber.State.HOLD)(fibers[]);
        fibers.remove(terminated);

        if (fibers.empty)
            break;

        foreach (fiber; fibers)
            fiber.call;

        handlePause;
        redraw;
    }
}
