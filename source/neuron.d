import std.math: floor, exp, sin, cos, PI;
import std.stdio;
import std.algorithm: min;
import std.conv: to;
import helpers;
import parameters;
import point;
import sdl;

class Neuron
{
    static Neuron root;
    static float calcTempFactor(float temp) { return 3 ^^ ((6.3 - temp) / 10); }

    Neuron parent;
    Neuron[] connected;
    Parameters params;
    float r, c, length = 0, angle = 0;

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

    @property Point start()
    {
        if (parent is null)
            return Point.center;
        else
            return parent.end;
    }

    @property Point end()
    {
        if (parent is null)
            return Point.center;
        else
            return start + Point(length * cos(angle), length * sin(angle));
    }

    this(Parameters params = randomParams, Neuron parent = null, int level = 0, int parentIndex = 0, float parentAngle = 0)
    {
        this.params = params;
        this.parent = parent;

        r = params.rho / (PI * params.a ^^ 2);
        c = 2 * PI * params.a * params.cap;
        float sectorSize = 0;

        if (level) {
            sectorSize = 2 * PI / (3 * level);
            angle = parentAngle + parentIndex * sectorSize,
            length = (sizeY / 5) * params.xTotal;
        }

        if (level > 0)
            return;

        foreach (i; 0..3)
            connected ~= new Neuron(randomParams, this, level + 1, i, angle - sectorSize / 2);
    }

    float[][] impulse(float v0, size_t segX = 50, float temp = 6.3)
    {
        float tempFactor = calcTempFactor(temp),
              deltaX = params.xTotal / segX,
              deltaT = min((r * c * deltaX ^^ 2) / 3, 10.0 ^^ -3);

        float[][] impulse = [];

        float[][] v = [[], []],
                  m = [[], []],
                  h = [[], []],
                  n = [[], []];

        foreach (i; 0..segX + 1) {
            m[0] ~= 0; m[1] ~= m0(0);
            h[0] ~= 0; h[1] ~= h0(0);
            n[0] ~= 0; n[1] ~= n0(0);
            v[0] ~= 0; v[1] ~= i <= segX / 4 ? v0 : 0;
        }

        foreach (j; 0..10000) {
            auto extent = v[1].extent;

            if (j * deltaT % 0.1 < 0.001) {
                impulse ~= v[1][1..$ - 1];
            }

            if (extent.max - extent.min < 0.5 * v0) {
                break;
            }

            m.swap(0, 1);
            h.swap(0, 1);
            n.swap(0, 1);
            v.swap(0, 1);

            foreach (i; 0..segX + 1) {
                m[1][i] = tempFactor * deltaT / tauM(v[0][i]) * (m0(v[0][i]) - m[0][i]) + m[0][i];
                h[1][i] = tempFactor * deltaT / tauH(v[0][i]) * (h0(v[0][i]) - h[0][i]) + h[0][i];
                n[1][i] = tempFactor * deltaT / tauN(v[0][i]) * (n0(v[0][i]) - n[0][i]) + n[0][i];

                float pNa = params.gNa * (v[0][i] - params.vNa) * m[0][i] ^^ 3 * h[0][i],
                      pK  = params.gK  * (v[0][i] - params.vK)  * n[0][i] ^^ 4,
                      pL  = params.gL  * (v[0][i] - params.vL),
                      p   = 2 * PI * params.a * (pNa + pK + pL);

                if (i == 0 || i == segX)
                    v[1][i] = 0;
                else
                    v[1][i] = deltaT / c * ((v[0][i + 1] - 2 * v[0][i] + v[0][i - 1]) / (deltaX ^^ 2 * r) - p) + v[0][i];
            }
        }

        return impulse;
    }
}
