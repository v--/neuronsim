module neuronsim.app;

import gtk.Main;

import neuronsim.sim.mutable_sim_wrapper;
import neuronsim.sim.neural_tree_sim;
import neuronsim.sim.sim_config;
import neuronsim.sim.sim_generator;
import neuronsim.sim.parameter_set;

import neuronsim.gui.control_box;
import neuronsim.gui.neural_tree_window;
import neuronsim.gui.error_dialog;

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

    void onGeneratorSuccess(MutableSimWrapper treeWrapper)
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
            window.canvas.updateSimWrapper(treeWrapper);
        }
    }

    auto generator = new SimGenerator(&onGeneratorPoll, &onGeneratorSuccess);

    void generateSim()
    {
        window.canvas.updateSimWrapper(null);
        window.controlBox.setOverallSensitive(false);
        generator.generate(window.controlBox.getValue());
    }

    void runAnimation()
    {
        window.canvas.animate();
    }

    window.controlBox.addOnGenerateClicked(box => generateSim());
    window.controlBox.addOnRunClicked(box => runAnimation());
    window.showAll();

    generateSim();

    Main.run();
}
