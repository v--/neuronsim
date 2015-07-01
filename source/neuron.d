module neuron;
import Dgame.Math;
import std.math: floor, exp, sin, cos, PI;
import std.functional: toDelegate;
import std.algorithm: min;
import std.conv: to;
import subscribed.pubsub;
import helpers;
import parameters;

class Neuron
{
    static float calcTempFactor(float temp) { return 3 ^^ ((6.3 - temp) / 10); }
    static Neuron root;

    Neuron parent;
    Neuron[] connected;
    Parameters params;
    float r, c, angle = 0;

    float alphaM(float v) { return v != 25 ? 0.1 * (25 - v) / (exp((25 - v)/10) - 1) : 1; }
    float betaM (float v) { return 4 * exp(-v / 18); }
    float m0    (float v) { return alphaM(v) / (alphaM(v) + betaM(v)); }
    float tauM  (float v) { return 1 / (alphaM(v) + betaM(v)); }

    float alphaH(float v) { return 0.08 * exp(-v / 20); }
    float betaH (float v) { return 1 / (exp((30 - v) / 10) + 1); }
    float h0    (float v) { return alphaH(v) / (alphaH(v) + betaH(v)); }
    float tauH  (float v) { return 1 / (alphaH(v) + betaH(v)); }

    float alphaN(float v) { return v != 10 ? 0.01 * (10 - v) / (exp((10 - v)/10) - 1) : 0.1; }
    float betaN (float v) { return 0.125 * exp(-v / 80); }
    float n0    (float v) { return alphaN(v) / (alphaN(v) + betaN(v)); }
    float tauN  (float v) { return 1 / (alphaN(v) + betaN(v)); }

    @property Vector2f start()
    {
        if (parent is null)
            return Vector2f.init;
        else
            return parent.end;
    }

    @property Vector2f end()
    {
        if (parent is null)
            return Vector2f.init;
        else
            return start + fromPolar(params.xTotal, angle);
    }

    this(Neuron parent = null, int level = 0, int scalar = 0)
    {
        this.parent = parent;
        params = randomParams;

        r = params.rho / (PI * params.a ^^ 2);
        c = 2 * PI * params.a * params.cap;

        if (level == 0)
            angle = 0;
        else if (level == 1)
            angle = scalar * 2 * PI / 3;
        else
            angle = parent.angle + scalar * PI / (2 + level);

        if (level > 2)
            return;

        foreach (i; -1..2)
            connected ~= new Neuron(this, level + 1, i);
    }

    float[][] impulse(float v0, size_t segX = 50, float temp = 6.3)
    {
        float tempFactor = calcTempFactor(temp),
              deltaX = params.xTotal / segX,
              deltaT = min((r * c * deltaX ^^ 2) / 3, 10.0 ^^ -3);

        float[][] impulse;

        float[] oldV, newV,
                oldM, newM,
                oldH, newH,
                oldN, newN;

        foreach (i; 0..segX + 1) {
            oldM ~= 0; newM ~= m0(0);
            oldH ~= 0; newH ~= h0(0);
            oldN ~= 0; newN ~= n0(0);
            oldV ~= 0; newV ~= i <= segX / 4 ? v0 : 0;
        }

        foreach (j; 0..10000) {
            auto extent = newV.extent;

            if (j * deltaT % 0.1 < 0.001) {
                impulse ~= newV[1..$ - 1];
            }

            if (extent.max - extent.min < 0.5 * v0) {
                break;
            }

            swap(oldM, newM);
            swap(oldH, newH);
            swap(oldN, newN);
            swap(oldV, newV);

            //foreach (i; 0..segX + 1) {
            //    newM[i] = tempFactor * deltaT / tauM(oldV[i]) * (m0(oldV[i]) - oldM[i]) + oldM[i];
            //    newH[i] = tempFactor * deltaT / tauH(oldV[i]) * (h0(oldV[i]) - oldH[i]) + oldH[i];
            //    newN[i] = tempFactor * deltaT / tauN(oldV[i]) * (n0(oldV[i]) - oldN[i]) + oldN[i];

            //    float pNa = params.gNa * (oldV[i] - params.vNa) * oldM[i] ^^ 3 * oldH[i],
            //          pK  = params.gK  * (oldV[i] - params.vK)  * oldN[i] ^^ 4,
            //          pL  = params.gL  * (oldV[i] - params.vL),
            //          p   = 2 * PI * params.a * (pNa + pK + pL);

            //    if (i == 0 || i == segX)
            //        newV[i] = 0;
            //    else
            //        newV[i] = deltaT / c * ((oldV[i + 1] - 2 * oldV[i] + oldV[i - 1]) / (deltaX ^^ 2 * r) - p) + oldV[i];
            //}
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
    Neuron.root = new Neuron;
}

shared static this()
{
    subscribe("rebuildNetwork", toDelegate(&rebuildNetwork));
}
