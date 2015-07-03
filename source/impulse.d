import std.math: floor, exp, sin, cos, PI;
import std.random: uniform;
import std.algorithm: max;
import std.conv: to;
import subscribed.pubsub;
import helpers;
import neuron;

enum int segX = 10;

class Impulse
{
    static float defaultv0 = 100;
    static Impulse root;

    float v0, endVoltage;
    float[][] matrix;

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

    @property float peak()
    {
        float peak;

        if (parent is null)
            peak = v0;
        else
            peak = matrix.extent!float.max;

        foreach (child; connected)
            peak = max(peak, child.peak);

        return max(peak, v0);
    }

    this(Neuron neuron, float v0 = defaultv0, Impulse parent = null)
    {
        publish("handleEvent");
        this.neuron = neuron;
        this.v0 = v0;
        this.parent = parent;
        matrix = neuron.impulse(v0, segX);
        endVoltage = (parent is null) ? v0 : endPeak;

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
    publish("showInfo", "Generating impulse...");
    publish("redraw");
    publish("blockInput", true);

    if (Impulse.root !is null)
        Impulse.root.destroy;

    Impulse.root = new Impulse(Neuron.root);
    publish("blockInput", false);
    publish("hideInfo");
    publish("redraw");
}

shared static this()
{
    subscribe("rebuildImpulse", toDelegate(&rebuildImpulse));
}
