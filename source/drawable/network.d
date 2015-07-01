module network;
import Dgame.System;
import Dgame.Window;
import Dgame.Graphic;
import Dgame.Math;
import std.algorithm: min;
import std.typecons: scoped;
import subscribed.pubsub;
import helpers;
import neuron;

string message;

void renderNetwork(Window* window, Font* font)
{
    auto size = window.getSize;
    auto center = Vector2f(size.width / 2, size.height / 2);
    auto factor = min(size.width, size.height) / 9.0;

    Vertex scale(Vector2f original)
    {
        return Vertex(
            center.x + original.x * factor,
            center.y + original.y * factor
        );
    }

    void drawNeuron(Neuron neuron)
    {
        auto a = scale(neuron.end);

        auto axon = scoped!Shape(Geometry.Lines,
            [
                scale(neuron.start),
                scale(neuron.end)
            ]
        );

        axon.fill = Shape.Fill.Line;
        axon.lineWidth = 3;
        axon.setColor(Color4b.White);
        window.draw(axon);

        auto head = scoped!Shape(10, *cast(Vector2f*)&a);
        head.fill = Shape.Fill.Full;
        head.setColor(Color4b.White);
        window.draw(head);

        foreach (subneuron; neuron.connected)
            drawNeuron(subneuron);
    }

    drawNeuron(Neuron.root);
}
