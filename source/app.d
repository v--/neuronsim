module neuronsim.app;

import neuronsim.gui.app : NeuronSimApp;

void main(string[] args)
{
    auto app = new NeuronSimApp();
    app.run(args);
}
