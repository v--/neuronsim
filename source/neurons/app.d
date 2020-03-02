module neurons.app;

import gtk.Main;

import neurons.computation.neural_tree_simulation_wrapper;
import neurons.computation.neural_tree_simulation;
import neurons.computation.simulation_generator;
import neurons.computation.parameter_set;

import neurons.gui.control_box;
import neurons.gui.neural_tree_window;

immutable(ParameterSet[]) createParamSet(ControlBox controlBox)
{
    import std.range : front, popFront, empty, generate, take;
    import std.array : array;

    return generate(&controlBox.getValue)
        .take(TREE_SIZE)
        .array()
        .idup();
}

void main(string[] args)
{
    Main.init(args);

    auto window = new NeuralTreeWindow();

    void onGeneratorPoll()
    {
        window.progressBar.pulse();
    }

    void onGeneratorSuccess(NeuralTreeSimulationWrapper treeWrapper)
    {
        window.controlBox.setSensitive(true);
        window.progressBar.setFraction(0);
        window.canvas.updateSimulationWrapper(treeWrapper);
    }

    auto generator = new SimulationGenerator(&onGeneratorPoll, &onGeneratorSuccess);

    void generateSimulation()
    {
        window.canvas.updateSimulationWrapper(null);
        window.controlBox.setSensitive(false);
        generator.generate(createParamSet(window.controlBox));
    }

    void runAnimation()
    {
        window.canvas.animate();
    }

    window.controlBox.addOnGenerateClicked(box => generateSimulation());
    window.controlBox.addOnRunClicked(box => runAnimation());
    window.showAll();

    generateSimulation();

    Main.run();
}
