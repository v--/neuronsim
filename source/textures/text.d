module text;
import texture;
import std.functional: toDelegate;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import subscribed;
import sdl;

private
{
    string message;
    Texture tex;
}

shared static this()
{
    tex = new Texture;
}

void renderMessage(string msg)
{
    hideMessage;
    message = msg;

    auto textSurface = TTF_RenderText_Shaded(font, msg.ptr, white, black);
    auto texture = renderer.SDL_CreateTextureFromSurface(textSurface);

    auto rect = SDL_Rect(
        (screen.x - textSurface.w) / 2,
        screen.y - textSurface.h - 50,
        textSurface.w,
        textSurface.h
    );

    renderer.SDL_RenderCopy(texture, null, &rect);
    SDL_FreeSurface(textSurface);
}

void render()
{
    renderMessage(message);
}

void hideMessage()
{
    tex.setRenderTarget;
    message = "";
    renderer.SDL_RenderClear;
}
