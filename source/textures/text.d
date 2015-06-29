static import common;
import std.functional: partial;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import global;

mixin common.Texture;

void renderMessage(string msg)
{
    hideMessage;
    message = msg;

    auto textSurface = TTF_RenderText_Shaded(font, msg.ptr, white, black);
    auto texture = renderer.SDL_CreateTextureFromSurface(textSurface);

    auto rect = SDL_Rect(
        (sizeX - textSurface.w) / 2,
        sizeY - textSurface.h - 50,
        textSurface.w,
        textSurface.h
    );

    renderer.SDL_RenderCopy(texture, null, &rect);
    SDL_FreeSurface(textSurface);
}

void hideMessage()
{
    setRenderTarget;
    message = "";
    renderer.SDL_RenderClear;
}
