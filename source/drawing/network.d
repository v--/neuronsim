module network;
import Dgame.System;
import Dgame.Window;
import Dgame.Graphic;
import Dgame.Math;
import subscribed.pubsub;
import helpers;
import neuron;

string message;

void renderNetwork(Window* window, Font* font)
{
    void drawNeuron(Neuron neuron)
    {
        auto offset = fromPolar(10, neuron.angle);
        auto start = pointScale(neuron.start) ;
        auto end = pointScale(neuron.end);
        window.drawLine(start + offset, end - offset);
        window.drawCircle(end);

        foreach (subneuron; neuron.connected)
            drawNeuron(subneuron);
    }

    drawNeuron(Neuron.root);
}
