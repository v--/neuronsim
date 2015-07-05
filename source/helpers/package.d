module helpers;
public import helpers.arrays;
public import helpers.graphics;
public import helpers.scales;
public import helpers.logger;
import events;

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
