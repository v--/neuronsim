import derelict.sdl2.sdl;
import global;
import sdl;

mixin template Texture()
{
    SDL_Texture* texture;
    private string message;
    alias setRenderTarget = partial!(common.setRenderTarget, texture);
    alias display = partial!(common.display, texture);
    alias updateTexture = partial!(common.updateTexture, texture);

    shared static this()
    {
        updateTexture;
        rendering ~= &display;
        textureUpdating ~= &updateTexture;
    }

    shared static ~this()
    {
        SDL_DestroyTexture(texture);
    }
}

void updateTexture(ref SDL_Texture* texture)
{
    if (texture !is null) {
        SDL_DestroyTexture(texture);
    }

    texture = renderer.SDL_CreateTexture(
        SDL_PIXELFORMAT_UNKNOWN,
        SDL_TEXTUREACCESS_TARGET,
        sizeX,
        sizeY
    );

    texture.SDL_SetTextureBlendMode(SDL_BLENDMODE_BLEND);

    if (texture is null)
        quit("Failed to update texture: %s");
}

void display(SDL_Texture* texture)
{
    resetRenderTarget;
    renderer.SDL_RenderCopy(texture, null, null);
}

void setRenderTarget(SDL_Texture* texture)
{
    if (renderer.SDL_SetRenderTarget(texture) != 0)
        quit("Unable to set rendering target to texture: %s");
}
