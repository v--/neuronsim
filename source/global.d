import std.typecons: Tuple;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import impulse;
import neuron;

__gshared SDL_Window* window;
__gshared SDL_Renderer* renderer;

__gshared TTF_Font* font;

__gshared SDL_Color white = SDL_Color(255, 255, 255, SDL_ALPHA_OPAQUE);
__gshared SDL_Color black = SDL_Color(0, 0, 0, SDL_ALPHA_OPAQUE);
__gshared SDL_Event lastEvent;

__gshared int sizeX = 800;
__gshared int sizeY = 600;

__gshared void function()[int] states;
__gshared void function()[] rendering;
__gshared void function()[] textureUpdating;

__gshared Neuron rootNeuron;
__gshared Impulse rootImpulse;

__gshared bool awaitingInput;
