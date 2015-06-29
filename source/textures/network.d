static import common;
import std.functional: partial;
import std.math: PI;
import derelict.sdl2.sdl;
import vector;
import global;
import sdl;

mixin common.Texture;

private void drawPoint(Vector vector)
{
    if (renderer.SDL_RenderDrawPoint(vector.x, vector.y) != 0)
        quit("Failed to draw a point: %s");
}

private void drawCircle(Vector center, float radius)
{
    foreach (circlePoint; 0..radius * 16) {
        auto vector = Vector.fromPolar(radius, PI / (radius * 8) * circlePoint);
        drawPoint(center + vector);
    }
}

void drawLine(Vector start, float length, float angle)
{
    setRenderTarget;

    auto starting = start;

    foreach (l; 0..length) {
        starting += Vector.fromPolar(1, angle);
        drawPoint(starting);
        drawPoint(starting + Vector.fromPolar(1, angle + PI / 2));
        drawPoint(starting + Vector.fromPolar(1, angle - PI / 2));
    }
}

void drawDisk(Vector center, int radius = 10)
{
    setRenderTarget;

    foreach (r; 1..radius) {
        drawCircle(center, r);
    }
}

void setPurple(ubyte shade)
{
    setRenderTarget;

    if (renderer.SDL_SetRenderDrawColor(shade, 48, shade, SDL_ALPHA_OPAQUE) != 0)
        quit("Failed change color: %s");
}

void resetColor()
{
    setPurple(48);
}
