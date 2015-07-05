import Dgame.System;
import Dgame.Window;
import Dgame.Graphic;
import Dgame.Math;
import derelict.sdl2.ttf;
import events;
import input;

// Catch segmentation faults
debug private version (linux)
{
    alias sighandler_t = void function(int);
    extern (C) sighandler_t signal(int signum, sighandler_t handler);

    void handler(int i)
    {
        throw new Error("SEGV");
    }

    shared static this()
    {
        import core.sys.posix.signal: SIGSEGV;
        signal(SIGSEGV, &handler);
    }
}

shared static this()
{
    TTF_Init();
}

shared static ~this()
{
    TTF_Quit();
}

void main()
{
    auto icon = Surface("res/icon.png");
    auto font = Font("res/liberation.ttf", 20);
    auto flags = Window.Style.Resizeable | Window.Style.Maximized;
    auto glSettings = GLContextSettings(GLContextSettings.AntiAlias.X8);
    auto window = Window(800, 600, "Neural simulation", flags, glSettings);
    Event event;

    void redraw()
    {
        resizeProjection(&window);
        window.clear;
        publish!"prerender"(&window, &font);
        publish!"render"(&window, &font);
        window.display;
    }

    void handleEvent()
    {
        bool simulate;

        if (window.poll(&event))
        {
            if (event.window.event == WindowEvent.Type.Resized || event.window.event == WindowEvent.Type.Exposed)
                redraw;

            else if (event.type == Event.Type.KeyDown)
                publish!"keyChange"(event.keyboard.key, simulate);

            if (simulate)
                publish!"simulate"(&window, &font);
        }
    }

    subscribe!"redraw"(&redraw);
    subscribe!"handleEvent"(&handleEvent);
    window.setIcon(icon);
    window.setClearColor(Color4b.Black);
    publish!"rebuildNetwork";

    while (true)
    {
        StopWatch.wait(5);
        handleEvent;
    }
}

void resizeProjection(Window* window)
{
    import derelict.opengl3.gl: glViewport;
    auto size = window.getSize;
    auto rect = Rect(0, 0, size.width, size.height);
    window.projection = window.projection.init;
    window.projection.ortho(rect);
    window.loadProjection();
    glViewport(0, 0, size.width, size.height);
}
