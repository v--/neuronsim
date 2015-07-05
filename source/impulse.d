import std.math: floor, exp, sin, cos, PI;
import std.random: uniform;
import std.algorithm: min, max;
import Dgame.Graphic;
import events;
import helpers;
import neuron;

enum int segX = 10;

class Impulse
{
    static float defaultv0 = 300;
    static Impulse root;

    float v0, endVoltage;
    float[][] matrix;
    Extent!float extent;
    Scale!(float, ubyte) colorScale;

    Neuron neuron;
    Impulse parent;
    Impulse[] connected;

    float endPeak()
    {
        if (parent is null)
            return v0;

        float[] end;

        foreach (row; matrix)
            end ~= row[$ - 2];

        return end.extent.max;
    }

    Color4b getColor(float number)
    {
        return Color4b(200, colorScale(number), 200);
    }

    this(Neuron neuron, float v0 = defaultv0, Impulse parent = null)
    {
        publish!"handleEvent";
        this.neuron = neuron;
        this.v0 = v0;
        this.parent = parent;

        if (parent is null)
        {
            extent = Extent!float(v0, v0, 0, 0);
            endVoltage = v0;
        }

        else
        {
            matrix = neuron.impulse(v0, segX);
            endVoltage = endPeak;
            extent = matrix.extent!float;

            colorScale = genLinscale!(float, ubyte)(
                extent.min, extent.max,
                255, 0
            );
        }

        publish!"impulseLog"([v0, endVoltage, 6.3, matrix.length / 10.0, neuron.params.tupleof]);

        if (neuron.connected.length == 0 || endVoltage == 0)
            return;

        auto childVoltage = endVoltage / neuron.connected.length;

        foreach (subneuron; neuron.connected)
        {
            auto bounds = [0.7 * childVoltage, 0.95 * childVoltage].extent;
            auto voltage = uniform(bounds.min, bounds.max);
            connected ~= new Impulse(subneuron, voltage, this);
        }
    }

    ~this()
    {
        foreach (child; connected)
            child.destroy;
    }
}

void rebuildImpulse()
{
    publish!"showInfo"("Generating impulse...");
    publish!"redraw";
    publish!"blockInput"(true);

    if (Impulse.root !is null)
        Impulse.root.destroy;

    Impulse.root = new Impulse(Neuron.root);
    publish!"blockInput"(false);
    publish!"hideInfo";
    publish!"redraw";
}

shared static this()
{
    subscribe!"rebuildImpulse"(&rebuildImpulse);
}
