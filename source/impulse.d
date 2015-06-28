import std.math: floor, exp, sin, cos, PI;
import std.random: uniform;
import std.algorithm: max;
import std.conv: to;
import helpers;
import neuron;

enum int seg = 10;

class Impulse
{
    static Impulse root;
    float v0, endVoltage;
    float[][] matrix;

    Neuron neuron;
    Impulse parent;
    Impulse[] connected;

    float endPeak()
    {
        float[] end;

        foreach (row; matrix)
            end ~= row[$ - 2];

        return end.extent.max;
    }

    @property float peak()
    {
        float peak = matrix.extent!float.max;

        foreach (child; connected)
            peak = max(peak, child.peak);

        return max(peak, v0);
    }

    this(Neuron neuron, float v0, Impulse parent = null)
    {
        this.neuron = neuron;
        this.v0 = v0;
        this.parent = parent;
        matrix = neuron.impulse(v0, seg);
        endVoltage = endPeak;

        if (neuron.connected.length == 0 || endVoltage == 0) {
            return;
        }

        auto childVoltage = endVoltage / neuron.connected.length;

        foreach (subneuron; neuron.connected) {
            auto voltage = uniform(0.7 * childVoltage, 0.95 * childVoltage);
            connected ~= new Impulse(subneuron, voltage, this);
        }
    }
}
