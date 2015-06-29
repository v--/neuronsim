module network;
import derelict.sdl2.sdl;
import std.math: PI;
import texture;
import subscribed;
import vector;
import sdl;

private Texture tex;

shared static this()
{
    tex = new Texture;
}

private void drawPoint(Vector vector)
{
    if (renderer.SDL_RenderDrawPoint(vector.x, vector.y) != 0)
        quit("Failed to draw a point: %s");
}

private void drawCircle(Vector center, float radius)
{
    foreach (circlePoint; 0..radius * 16)
    {
        auto vector = Vector.fromPolar(radius, PI / (radius * 8) * circlePoint);
        drawPoint(center + vector);
    }
}

void drawLine(Vector start, float length, float angle)
{
    tex.setRenderTarget;
    auto starting = start;

    foreach (l; 0..length)
    {
        starting += Vector.fromPolar(1, angle);
        drawPoint(starting);
        drawPoint(starting + Vector.fromPolar(1, angle + PI / 2));
        drawPoint(starting + Vector.fromPolar(1, angle - PI / 2));
    }
}

void drawDisk(Vector center, int radius = 10)
{
    tex.setRenderTarget;

    foreach (r; 1..radius)
        drawCircle(center, r);
}

void setPurple(ubyte shade)
{
    tex.setRenderTarget;

    if (renderer.SDL_SetRenderDrawColor(shade, 48, shade, SDL_ALPHA_OPAQUE) != 0)
        quit("Failed change color: %s");
}

void resetColor()
{
    setPurple(48);
}
