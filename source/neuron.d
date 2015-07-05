import Dgame.Math;
import std.random: uniform;
import std.math: floor, exp, sin, cos, PI;
import std.algorithm: min;
import std.conv: to;
import parameters;
import helpers;
import events;

private
{
    alias FloatFunc = pure float function(float);

    mixin template Channel(FloatFunc A, FloatFunc B)
    {
        float zero(float voltage)
        {
            return A(voltage) / (A(voltage) + B(voltage));
        }

        float tau(float voltage)
        {
            return 1 / (A(voltage) + B(voltage));
        }
    }

    mixin Channel!(
        v => v != 25 ? 0.1 * (25 - v) / (exp((25 - v)/10) - 1) : 1,
        v => 1 * exp(-v / 18)
    ) m;

    mixin Channel!(
        v => 0.08 * exp(-v / 20),
        v => 1 / (exp((30 - v) / 10) + 1)
    ) h;

    mixin Channel!(
        v => v != 10 ? 0.01 * (10 - v) / (exp((10 - v)/10) - 1) : 0.1,
        v => 0.125 * exp(-v / 80)
    ) n;
}

class Neuron
{
    static FloatFunc calcTempFactor = temp => 3 ^^ ((6.3 - temp) / 10);
    static Neuron root;

    Neuron parent;
    Neuron[] connected;
    Parameters params;
    Vector2f start, end;
    immutable float r, c, angle;

    Vector2f point(float point)
    in
    {
        assert(point >= 0 && point <= 1);
    }
    body
    {
        if (parent is null)
            return Vector2f.init;
        else
            return parent.end + fromPolar(params.xTotal * point, angle);
    }

    this(Neuron parent = null, int level = 0, int scalar = 0)
    {
        this.parent = parent;

        if (level == 0)
            angle = 0;
        else if (level == 1)
            angle = scalar * 2 * PI / 3;
        else
            angle = parent.angle + scalar * PI / (3.0/2 + level);

        params = Parameters.random;
        r = params.rho / (PI * params.a ^^ 2);
        c = 2 * PI * params.a * params.cap;
        start = point(0);
        end = point(1);

        if (level > 2)
            return;

        foreach (i; -1..2)
            connected ~= new Neuron(this, level + 1, i);
    }

    float[][] impulse(float v0, size_t segX = 25, float temp = 6.3)
    {
        immutable tempFactor = calcTempFactor(temp),
                  deltaX = params.xTotal / segX,
                  deltaT = min((r * c * deltaX ^^ 2) / 3, 1e-3),
                  treshold = min(50, v0 / 3);

        float[][] impulse;

        float[] oldV, newV,
                oldM, newM,
                oldH, newH,
                oldN, newN;

        oldV.length = oldM.length = oldH.length = oldN.length =
        newV.length = newM.length = newH.length = newN.length = segX + 3;

        newM[] = m.zero(0);
        newH[] = h.zero(0);
        newN[] = n.zero(0);
        newV[segX / 4..$] = 0;
        newV[0..segX / 4] = v0;

        foreach (j; 0..5_000) {
            auto extent = newV.extent;

            if (j * deltaT % 0.1 < 1e-3)
                impulse ~= newV[1..$ - 1].dup;

            if (extent.max - extent.min < treshold)
                break;

            swap(oldM, newM);
            swap(oldH, newH);
            swap(oldN, newN);
            swap(oldV, newV);

            foreach (i; 0..segX + 3)
            {
                immutable v = oldV[i];

                newH[i] = tempFactor * deltaT / h.tau(v) * (h.zero(v) - oldH[i]) + oldH[i];
                newM[i] = tempFactor * deltaT / m.tau(v) * (m.zero(v) - oldM[i]) + oldM[i];
                newN[i] = tempFactor * deltaT / n.tau(v) * (n.zero(v) - oldN[i]) + oldN[i];

                immutable pNa = params.gNa * (v - params.vNa) * oldM[i] ^^ 3 * oldH[i],
                          pK  = params.gK  * (v - params.vK)  * oldN[i] ^^ 4,
                          pL  = params.gL  * (v - params.vL),
                          p   = 2 * PI * params.a * (pNa + pK + pL);

                if (i == 0 || i == segX + 2)
                    newV[i] = 0;
                else
                    newV[i] = deltaT / c * ((oldV[i + 1] - 2 * v + oldV[i - 1]) / (deltaX ^^ 2 * r) - p) + v;
            }
        }

        return impulse;
    }

    ~this()
    {
        foreach (subneuron; connected)
            subneuron.destroy;
    }
}

void rebuildNetwork()
{
    if (Neuron.root !is null)
        Neuron.root.destroy;

    Neuron.root = new Neuron;
    publish!"rebuildImpulse";
}

shared static this()
{
    subscribe!"rebuildNetwork"(&rebuildNetwork);
}
