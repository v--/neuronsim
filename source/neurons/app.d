module neurons.app;

import gtk.Main;

import neurons.computation.mutable_simulation_wrapper;
import neurons.computation.neural_tree_simulation;
import neurons.computation.simulation_config;
import neurons.computation.simulation_generator;
import neurons.computation.parameter_set;

import neurons.gui.control_box;
import neurons.gui.neural_tree_window;
import neurons.gui.error_dialog;

void main(string[] args)
{
    Main.init(args);

    auto window = new NeuralTreeWindow();

    void onErrorOKClicked(ErrorDialog dialog)
    {
        dialog.destroy();
        window.controlBox.setGenerateButtonSensitive(true);
    }

    void onGeneratorPoll()
    {
        window.progressBar.pulse();
    }

    void onGeneratorSuccess(MutableSimulationWrapper treeWrapper)
    {
        window.progressBar.setFraction(0);

        if (treeWrapper.tree is null)
        {
            auto dialog = new ErrorDialog(window, "Could not generate the neuron tree");
            dialog.addOnOKResponse(&onErrorOKClicked);
            dialog.run();
        }
        else
        {
            window.controlBox.setOverallSensitive(true);
            window.canvas.updateSimulationWrapper(treeWrapper);
        }
    }

    auto generator = new SimulationGenerator(&onGeneratorPoll, &onGeneratorSuccess);

    void generateSimulation()
    {
        window.canvas.updateSimulationWrapper(null);
        window.controlBox.setOverallSensitive(false);
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
