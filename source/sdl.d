import derelict.sdl2.sdl;
import std.c.stdlib : exit;
import std.stdio : writefln;
import std.math : sin, cos;
import helpers;
import point;
import neuron;
import impulse;
import simulation;

SDL_Window* window;
SDL_Renderer* renderer;

int sizeX = 800;
int sizeY = 600;

shared static this()
{
    DerelictSDL2.load();

    if (SDL_Init(SDL_INIT_EVERYTHING) != 0)
    {
        writefln("Failed to initialize SDL : %s", SDL_GetError());
        exit(1);
    }

    window = SDL_CreateWindow(
        "Neuron simulation",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        sizeX,
        sizeY,
        SDL_WINDOW_RESIZABLE | SDL_WINDOW_MAXIMIZED
    );

    if (window is null)
    {
        writefln("Failed to create window : %s", SDL_GetError());
        exit(1);
    }

    renderer = window.SDL_CreateRenderer(-1, SDL_RENDERER_ACCELERATED);

    if (renderer is null)
    {
        writefln("Failed to create renderer : %s", SDL_GetError());
        exit(1);
    }

    renderer.SDL_RenderClear;
    renderer.SDL_RenderPresent;
}

shared static ~this()
{
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
}

void updateScreenSize()
{
    renderer.SDL_SetRenderDrawColor(0, 0, 0, SDL_ALPHA_OPAQUE);
    renderer.SDL_RenderClear;
    window.SDL_GetWindowSize(&sizeX, &sizeY);
    renderer.SDL_RenderSetLogicalSize(sizeX, sizeY);
}

void enterEventLoop()
{
    SDL_Event event;

    while (SDL_WaitEvent(&event) >= 0) {
        if (event.type == SDL_WINDOWEVENT) {
            redraw;
            continue;
        }

        if (event.type != SDL_KEYUP) {
            continue;
        }

        switch (event.key.keysym.sym) {
            case SDLK_ESCAPE:
                exit(0);
                break;

            case SDLK_SPACE:
                runSimulation;
                break;

            case SDLK_r:
                return;

            default:
                break;
        }
    }
}

void redraw()
{
    updateScreenSize;
    drawNeuron;
    render;
}

void rebuild()
{
    Neuron.root = new Neuron;
    Impulse.root = new Impulse(Neuron.root, 100);
}

void render()
{
    renderer.SDL_RenderPresent;
}

void drawPoint(Point point)
{
    renderer.SDL_RenderDrawPoint(point.x, point.y);
}

void drawLine(Point start, float length, float angle)
{
    auto starting = start;

    foreach (l; 0..length) {
        starting += Point.fromPolar(1, angle);
        drawPoint(starting);
        drawPoint(starting + Point.fromPolar(1, angle + PI / 2));
        drawPoint(starting + Point.fromPolar(1, angle - PI / 2));
    }
}

void drawCircle(Point center, float radius)
{
    foreach (circlePoint; 0..radius * 16) {
        auto point = Point.fromPolar(radius, PI / (radius * 8) * circlePoint);
        drawPoint(center + point);
    }
}

void drawDisk(Point center, int radius = 10)
{
    foreach (r; 1..radius) {
        drawCircle(center, r);
    }
}

void setPurple(ubyte shade)
{
    renderer.SDL_SetRenderDrawColor(shade, 48, shade, SDL_ALPHA_OPAQUE);
}

void resetColor()
{
    setPurple(48);
}
