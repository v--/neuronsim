import sdl;
import helpers;

struct Point
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

    static Point center()
    {
        return Point(sizeX / 2, sizeY / 2);
    }

    static Point fromPolar(float length, float angle)
    {
        return Point(length * cos(angle), length * sin(angle));
    }

    this(float x, float y)
    {
        _x = x;
        _y = y;
    }

    void opOpAssign(string s)(Point rhl) if (s == "+")
    {
        _x += rhl._x;
        _y += rhl._y;
    }

    Point opBinary(string s)(Point rhl) if (s == "+")
    {
        return Point(_x + rhl._x, _y + rhl._y);
    }

    Point opBinary(string s)(Point rhl) if (s == "-")
    {
        return Point(_x - rhl._x, _y - rhl._y);
    }

    Point opBinary(string s)(float scalar) if (s == "*")
    {
        return Point(_x * scalar, _y * scalar);
    }

    Point opBinary(string s)(float scalar) if (s == "/")
    {
        return Point(_x / scalar, _y / scalar);
    }
}
