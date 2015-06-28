public import std.stdio: writeln;
import std.typecons: Tuple;

alias Linscale(T) = T delegate(T);
alias Extent(T) = Tuple!(
    T, "min",
    T, "max",
    size_t, "minIndex",
    size_t, "maxIndex"
);

Linscale!T linscale(T)(T[2] domain, T[2] range)
{
    T scalar = (range[1] - range[0]) / (domain[1] - domain[0]);

    T scale(T input)
    {
        return range[0] + scalar * (input - domain[0]);
    }

    return &scale;
}

unittest
{
    auto scale = linscale!float([0, 1], [0, 10]);
    assert(scale(0.5) == 5);
    assert(scale(5) == 50);
    assert(scale(-5) == -50);
}

T[] compress(T)(T[] array, size_t size)
in
{
    assert(size <= array.length);
}
body
{
    auto step = cast(float)array.length / size;
    T[] compressed;
    compressed.length = size;
    size_t currStep = 0;

    foreach (i; 0..array.length) {
        if (i % step < 1) {
            compressed[currStep++] = array[i];
        }
    }

    return compressed;
}

unittest
{
    assert(compress([1, 2, 3, 4, 5], 5) == [1, 2, 3, 4, 5]);
    assert(compress([1, 2, 3, 4, 5], 3) == [1, 3, 5]);
}

void swap(T)(T[] array, size_t a, size_t b)
in
{
    assert(a >= 0);
    assert(a < array.length);
    assert(b >= 0);
    assert(b < array.length);
}
body
{
    auto temp = array[b];
    array[b] = array[a];
    array[a] = temp;
}

Extent!T extent(T)(T[] array)
in
{
    assert(array.length > 0);
}
body
{
    size_t minIndex, maxIndex;

    foreach (i, item; array) {
        if (item < array[minIndex])
            minIndex = i;
        if (item > array[maxIndex])
            maxIndex = i;
    }

    return Extent!T(array[minIndex], array[maxIndex], minIndex, maxIndex);
}

Extent!T extent(T)(T[][] matrix)
in
{
    assert(matrix.length > 0);
}
body
{
    auto result = matrix[0].extent;

    foreach (i, row; matrix[1..$]) {
        auto potential = row.extent;

        if (potential.min < result.min) {
            result.min = potential.min;
            result.minIndex = i;
        }

        if (potential.max > result.max) {
            result.max = potential.max;
            result.maxIndex = i;
        }
    }

    return result;
}
