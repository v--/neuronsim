module helpers.graphics;
import std.math: sin, cos;
import std.algorithm: min;
import std.typecons: scoped;
import Dgame.Math;
import Dgame.Graphic;
import Dgame.System;
import events;

alias PointScale = Vector2f delegate(Vector2f);

PointScale pointScale;

void updateScale(Window* window, Font* font)
{
    pointScale = genPointScale(window);
}

Vector2f fromPolar(float length, float angle)
{
    return Vector2f(length * cos(angle), length * sin(angle));
}

Vertex toVertex(Vector2f vector)
{
    return *cast(Vertex*)&vector;
}

PointScale genPointScale(Window* window)
{
    auto size = window.getSize;
    auto center = Vector2f(size.width / 2, size.height / 2);
    auto factor = min(size.width, size.height) / 9.0;

    Vector2f scale(Vector2f original)
    {
        return Vector2f(
            center.x + original.x * factor,
            center.y + original.y * factor
        );
    }

    return &scale;
}

void drawCircle(Window* window, Vector2f center, Color4b color = Color4b.White)
{
    auto circle = scoped!Shape(10, center);
    circle.setColor(color);
    window.draw(circle);
}

void drawLine(Window* window, Vector2f start, Vector2f end, Color4b color = Color4b.White)
{
    auto line = scoped!Shape(Geometry.Lines, [start.toVertex, end.toVertex]);
    line.lineWidth = 3;
    line.setColor(color);
    window.draw(line);
}

void refineText(Text text)
{
    text.foreground = Color4b.White;
    text.background = Color4b(0, 0, 0, 0);
    text.mode = Font.Mode.Shaded;
}

shared static this()
{
    subscribe!"prerender"(&updateScale);
}
