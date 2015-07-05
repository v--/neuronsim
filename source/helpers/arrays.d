module helpers.arrays;
import std.algorithm: min;
import std.typecons: Tuple;
import std.math: sin, cos;

struct Extent(T)
{
    T min;
    T max;
    size_t minIndex;
    size_t maxIndex;
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

bool hasTruth(bool[] array)
{
    foreach (element; array)
        if (element)
            return true;

    return false;
}
