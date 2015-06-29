import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import subscribed;
import helpers;
import vector;

private SDL_Event event;

SDL_Renderer* renderer;
SDL_Window* window;
TTF_Font* font;

auto white = SDL_Color(255, 255, 255, SDL_ALPHA_OPAQUE);
auto black = SDL_Color(0, 0, 0, SDL_ALPHA_OPAQUE);
auto screen = Vector(800, 600);

shared static this()
{
    DerelictSDL2.load;

    if (SDL_Init(SDL_INIT_EVERYTHING) != 0)
        quit("Failed to initialize SDL");

    window = SDL_CreateWindow(
        "Neural network simulation",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        screen.x,
        screen.y,
        SDL_WINDOW_RESIZABLE | SDL_WINDOW_MAXIMIZED
    );

    if (window is null)
        quit("Failed to create window");

    renderer = window.SDL_CreateRenderer(-1, SDL_RENDERER_ACCELERATED | SDL_RENDERER_TARGETTEXTURE);

    if (renderer is null)
        quit("Failed to create renderer");

    renderer.SDL_RenderClear;
}

shared static this()
{
    DerelictSDL2ttf.load;

    if (TTF_Init() != 0)
        quit("Failed to initialize SDL TTF ");

    font = TTF_OpenFont("liberation.ttf", 20);

    if (font is null)
        quit("Failed to load font");
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
    printf("%s: %s\n", message, SDL_GetError());
    exit(1);
}

void resetRenderTarget()
{
    renderer.SDL_SetRenderTarget(null);
}

void updateScreenSize()
{
    int x, y;
    resetRenderTarget;
    renderer.SDL_SetRenderDrawColor(0, 0, 0, SDL_ALPHA_OPAQUE);
    renderer.SDL_RenderClear;
    window.SDL_GetWindowSize(&x, &y);
    renderer.SDL_RenderSetLogicalSize(x, y);
    screen = Vector(x, y);
}

void redraw()
{
    updateScreenSize;
    publish("updateTextures");
    publish("render");

    resetRenderTarget;
    renderer.SDL_RenderClear;

    publish("redraw");

    resetRenderTarget;
    renderer.SDL_RenderPresent;
}

void handleEvent()
{
    if (event.type == SDL_WINDOWEVENT && (
        event.window.event == SDL_WINDOWEVENT_RESIZED ||
        event.window.event == SDL_WINDOWEVENT_EXPOSED))
        redraw;

    else if (event.type == SDL_KEYUP)
        publish("keyChange", event.key.keysym.sym);
}

void handlePause(int timeout = 25)
{
    if (SDL_WaitEventTimeout(&event, timeout))
        handleEvent;
}

void enterEventLoop()
{
    while (true)
        handlePause;
}
