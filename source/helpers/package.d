module helpers;
public import helpers.arrays;
public import helpers.graphics;
debug public import std.stdio: writeln, writefln;

alias Linscale(T, E) = E delegate(T);

Linscale!(T, E) genLinscale(T, E)(T dMin, T dMax, E rMin, E rMax)
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

void swap(T)(ref T a, ref T b)
{
    auto temp = a;
    a = b;
    b = temp;
}

unittest
{
    auto array1 = [0, 1, 2];
    auto array2 = [1, 2, 3];
    swap(array1, array2);
    assert(array1 == [1, 2, 3]);
    assert(array2 == [0, 1, 2]);
}
