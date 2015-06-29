import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import helpers;
import global;

shared static this()
{
    DerelictSDL2.load;

    if (SDL_Init(SDL_INIT_EVERYTHING) != 0)
        quit("Failed to initialize SDL: %s");

    window = SDL_CreateWindow(
        "Neural network simulation",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        sizeX,
        sizeY,
        SDL_WINDOW_RESIZABLE | SDL_WINDOW_MAXIMIZED
    );

    if (window is null)
        quit("Failed to create window: %s");

    renderer = window.SDL_CreateRenderer(-1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);

    if (renderer is null)
        quit("Failed to create renderer: %s");

    renderer.SDL_RenderClear;
}

shared static this()
{
    DerelictSDL2ttf.load;

    if (TTF_Init() != 0)
        quit("Failed to initialize SDL TTF : %s");

    font = TTF_OpenFont("liberation.ttf", 20);

    if (font is null)
        quit("Failed to load font: %s");
}

shared static ~this()
{
    TTF_CloseFont(font);
    TTF_Quit();
}

shared static ~this()
{
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);
    SDL_Quit();
}

void quit(const(char)* message)
{
    import std.c.stdlib: exit;
    import std.c.stdio: printf;
    printf(message, SDL_GetError());
    exit(1);
}

void resetRenderTarget()
{
    renderer.SDL_SetRenderTarget(null);
}

void updateScreenSize()
{
    renderer.SDL_SetRenderDrawColor(0, 0, 0, SDL_ALPHA_OPAQUE);
    renderer.SDL_RenderClear;
    window.SDL_GetWindowSize(&sizeX, &sizeY);
    renderer.SDL_RenderSetLogicalSize(sizeX, sizeY);
}

void redraw()
{
    resetRenderTarget;
    renderer.SDL_RenderClear;

    foreach (func; rendering)
        func();

    renderer.SDL_RenderPresent;
}

void handleEvent()
{
    switch (lastEvent.type) {
        case SDL_WINDOWEVENT:
            switch (lastEvent.window.event) {
                case SDL_WINDOWEVENT_RESIZED, SDL_WINDOWEVENT_EXPOSED:
                    updateScreenSize;

                    foreach (func; textureUpdating)
                        func();

                    redraw;
                    break;

                default: break;
            }

            break;

        case SDL_KEYUP:
            if (lastEvent.key.keysym.sym in states)
                states[lastEvent.key.keysym.sym]();

            break;

        default: break;
    }
}

void handlePause(int timeout = 25)
{
    if (SDL_WaitEventTimeout(&lastEvent, timeout))
        handleEvent;
}

void enterEventLoop()
{
    while (true)
        handlePause;
}
