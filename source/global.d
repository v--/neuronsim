import std.typecons: Tuple;
import derelict.sdl2.sdl;
import derelict.sdl2.ttf;
import subscribed;
import impulse;
import neuron;

__gshared Neuron rootNeuron;
__gshared Impulse rootImpulse;

__gshared bool awaitingInput;
