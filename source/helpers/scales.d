module helpers.scales;
import std.math: pow;

alias Scale(T, E) = E delegate(T);

Scale!(T, E) genLinscale(T, E)(T dMin, T dMax, E rMin, E rMax)
{
    T scalar = (rMax - rMin) / (dMax - dMin);

    E scale(T input)
    {
        return cast(E)(rMin + scalar * (input - dMin));
    }

    return &scale;
}

unittest
{
    auto scale = genLinscale!(float, int)(0, 1, 0, 10);
    assert(scale(0.5) == 5);
    assert(scale(5) == 50);
    assert(scale(-5) == -50);
}
