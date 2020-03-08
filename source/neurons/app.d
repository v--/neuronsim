module neurons.app;

import gtk.Main;

import neurons.computation.mutable_simulation_wrapper;
import neurons.computation.neural_tree_simulation;
import neurons.computation.simulation_config;
import neurons.computation.simulation_generator;
import neurons.computation.parameter_set;

import neurons.gui.control_box;
import neurons.gui.neural_tree_window;

void main(string[] args)
{
    Main.init(args);

    auto window = new NeuralTreeWindow();

    void onGeneratorPoll()
    {
        window.progressBar.pulse();
    }

    void onGeneratorSuccess(MutableSimulationWrapper treeWrapper)
    {
        window.progressBar.setFraction(0);
        window.controlBox.setSensitive(true);
        window.canvas.updateSimulationWrapper(treeWrapper);
    }

    auto generator = new SimulationGenerator(&onGeneratorPoll, &onGeneratorSuccess);

    void generateSimulation()
    {
        window.canvas.updateSimulationWrapper(null);
        window.controlBox.setSensitive(false);
        generator.generate(window.controlBox.getValue());
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
