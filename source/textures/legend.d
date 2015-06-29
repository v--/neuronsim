module legend;
import std.functional: toDelegate;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import subscribed;
import texture;
import sdl;
import helpers;

private
{
    Texture tex;

    static enum legend = [
        "Legend:",
        "'r' to generate another network",
        "'v' to change initial voltage",
        "'space' to launch impulse",
        "'esc' to quit"
    ];
}

shared static this()
{
    tex = new Texture;
    subscribe("render", toDelegate(&render));
}

void render()
{
    tex.setRenderTarget;
    auto offsetTop = 50;

    foreach (str; legend)
    {
        auto textSurface = TTF_RenderText_Shaded(font, str.ptr, white, black);
        auto texture = renderer.SDL_CreateTextureFromSurface(textSurface);

        auto rect = SDL_Rect(
            50,
            offsetTop,
            textSurface.w,
            textSurface.h
        );

        offsetTop += textSurface.h + 10;

        renderer.SDL_RenderCopy(texture, null, &rect);
        SDL_FreeSurface(textSurface);
    }
}
