static import common;
import std.functional: partial;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import global;
import sdl;

mixin common.Texture;

private static enum legend = [
    "Legend:",
    "'r' to generate another network",
    "'v' to change initial voltage",
    "'space' to launch impulse",
    "'esc' to quit"
];

void render()
{
    setRenderTarget;
    auto offsetTop = 50;

    foreach (str; legend) {
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
