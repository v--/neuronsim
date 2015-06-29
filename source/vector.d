import std.math: sin, cos;
import helpers;
import sdl;
import global;

//struct Vector(T, L) if (T == float, L == 2)
struct Vector
{
    float _x, _y;

    @property int x()
    {
        return cast(int)_x;
    }

    @property int y()
    {
        return cast(int)_y;
    }

    static Vector center()
    {
        return Vector(sizeX / 2, sizeY / 2);
    }

    static Vector fromPolar(float length, float angle)
    {
        return Vector(length * cos(angle), length * sin(angle));
    }

    this(float x, float y)
    {
        _x = x;
        _y = y;
    }

    void opOpAssign(string s)(Vector rhl) if (s == "+")
    {
        _x += rhl._x;
        _y += rhl._y;
    }

    Vector opBinary(string s)(Vector rhl) if (s == "+")
    {
        return Vector(_x + rhl._x, _y + rhl._y);
    }

    Vector opBinary(string s)(Vector rhl) if (s == "-")
    {
        return Vector(_x - rhl._x, _y - rhl._y);
    }

    Vector opBinary(string s)(float scalar) if (s == "*")
    {
        return Vector(_x * scalar, _y * scalar);
    }

    Vector opBinary(string s)(float scalar) if (s == "/")
    {
        return Vector(_x / scalar, _y / scalar);
    }
}
