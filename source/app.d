import derelict.sdl2.types;
import helpers;
import sdl;
import subscribed;
import impulse;
import neuron;
import simulation;
import input;
import textures;
import global;

void simulate()
{
    awaitingInput = false;
    publish("redraw");
    runSimulation;
}

void rebuildNetwork()
{
    awaitingInput = false;
    rootNeuron.destroy;
    rootNeuron = new Neuron;
    rootImpulse.destroy;
    rootImpulse = new Impulse(rootNeuron);
    publish("redraw");
}

void main()
{
    //redraw;
    enterEventLoop;
}
