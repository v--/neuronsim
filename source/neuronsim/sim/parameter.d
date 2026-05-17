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

        if (r <= (this.mode - this.min) / (this.max - this.min))
            return this.min + sqrt(r * (this.mode - this.min) * (this.max - this.min));

        return this.max - sqrt((1 - r) * (this.max - this.mode) * (this.max - this.min));
    }
}
