import derelict.sdl2.types;
import global;
import helpers;
import sdl;
import impulse;
import neuron;
import simulation;
import input;
import textures;

void exit()
{
    import std.c.stdlib: exit;
    exit(0);
}

void simulate()
{
    text.hideMessage;
    awaitingInput = false;
    redraw;
    runSimulation;
}

void rebuildNetwork()
{
    text.hideMessage;
    awaitingInput = false;
    rootNeuron.destroy;
    rootNeuron = new Neuron;
    rootImpulse.destroy;
    rootImpulse = new Impulse(rootNeuron);
    redraw;
}

void asdf()
{
    legend.render;
}

void main()
{
    states[SDLK_r] = &rebuildNetwork;
    states[SDLK_v] = &startChangeVoltage;
    states[SDLK_ESCAPE] = &exit;
    states[SDLK_RETURN] = &endChangeVoltage;
    states[SDLK_SPACE] = &simulate;
    states[SDLK_0] = &numericInput;
    states[SDLK_1] = &numericInput;
    states[SDLK_2] = &numericInput;
    states[SDLK_3] = &numericInput;
    states[SDLK_4] = &numericInput;
    states[SDLK_5] = &numericInput;
    states[SDLK_6] = &numericInput;
    states[SDLK_7] = &numericInput;
    states[SDLK_8] = &numericInput;
    states[SDLK_9] = &numericInput;
    states[SDLK_MINUS] = &numericInput;
    states[SDLK_BACKSPACE] = &numericInput;

    rendering ~= &asdf;

    //redraw;
    enterEventLoop;
}
