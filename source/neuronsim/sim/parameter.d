module neuronsim.sim.parameter;

struct Parameter
{
    string name;
    string unit;
    double mode;
    double min;
    double max;
    double step = double.nan;

    // Simulate a triangular distribution
    double simulateTriangular()
    {
        import std.math : sqrt;
        import std.random : uniform01;

        immutable r = uniform01();

        if (r <= (mode - min) / (max - min))
            return min + sqrt(r * (mode - min) * (max - min));

        return max - sqrt((1 - r) * (max - mode) * (max - min));
    }
}
