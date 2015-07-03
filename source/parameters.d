import Dgame.Math;
import std.random: uniform;
import helpers;

struct Parameters
{
    static min  = Parameters(0.80, 1.00, 20.0, 0.80, 65.00, 26.0, 0.13, 95.00, -14.0, 4.00);
    static max  = Parameters(1.40, 3.00, 50.0, 1.50, 260.0, 49.0, 0.50, 119.0, -9.00, 22.0);
    static mean = Parameters(1.00, 2.38, 35.4, 0.91, 120.0, 34.0, 0.26, 109.0, -11.0, 11.0);

    static random()
    {
        Parameters result;
        auto minTuple = min.tupleof;
        auto maxTuple = max.tupleof;

        foreach (key, ref value; result.tupleof)
            value = uniform(minTuple[key], maxTuple[key]);

        return result;
    }

    float xTotal, a, rho, cap, gNa, gK, gL, vNa, vK, vL;
}
