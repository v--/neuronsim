module texture;
import derelict.sdl2.sdl;
import subscribed;
import sdl;

class Texture
{
    SDL_Texture* texture;

    this()
    {
        updateTexture;
        subscribe("updateTextures", &updateTexture);
        subscribe("redraw", &display);
    }

    void display()
    {
        resetRenderTarget;
        renderer.SDL_RenderCopy(texture, null, null);
    }

    void updateTexture()
    {
        if (texture !is null) {
            SDL_DestroyTexture(texture);
        }

        texture = renderer.SDL_CreateTexture(
            SDL_PIXELFORMAT_UNKNOWN,
            SDL_TEXTUREACCESS_TARGET,
            screen.x,
            screen.y
        );

        if (texture is null)
            quit("Failed to update texture: %s");

        setRenderTarget;
        renderer.SDL_RenderClear;
        renderer.SDL_RenderPresent;
        texture.SDL_SetTextureBlendMode(SDL_BLENDMODE_BLEND);
    }

    void setRenderTarget()
    {
        if (renderer.SDL_SetRenderTarget(texture) != 0)
            quit("Unable to set rendering target to texture: %s");
    }

    ~this()
    {
        SDL_DestroyTexture(texture);
    }
}
