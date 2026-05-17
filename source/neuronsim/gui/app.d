module neuronsim.gui.app;

import adw.application : Application;
import gio.types : ApplicationFlags;

import neuronsim.gui.control_box;
import neuronsim.gui.error_dialog;
import neuronsim.gui.neural_tree_window;
import neuronsim.sim.mutable_sim_wrapper;
import neuronsim.sim.neural_tree_sim;
import neuronsim.sim.sim_generator;

class NeuronSimApp : Application
{
    NeuralTreeWindow window;

    private
    {
        SimGenerator generator;

        void onErrorDismissed(ErrorDialog dialog)
        {
            dialog.destroy();
            this.window.controlBox.setGenerateButtonSensitive(true);
        }

        void onGeneratorPoll()
        {
            this.window.progressBar.pulse();
        }

        void onGeneratorSuccess(MutableSimWrapper treeWrapper)
        {
            import std.stdio: writeln; writeln("succ");
            this.window.progressBar.setFraction(0);

            if (treeWrapper.tree is null)
            {
                auto dialog = new ErrorDialog("Could not generate the neuron tree");
                dialog.connectClose(&this.onErrorDismissed);
                dialog.present();
            }
            else
            {
                this.window.controlBox.setOverallSensitive(true);
                this.window.canvas.updateSimWrapper(treeWrapper);
            }
        }
    }

    this()
    {
        super("net.ivasilev.NeuronSim", ApplicationFlags.DefaultFlags);
        this.connectActivate(&this.onActivate);
    }

    void generateSim()
    {
        this.window.canvas.updateSimWrapper(null);
        this.window.controlBox.setOverallSensitive(false);
        this.generator.generate(this.window.controlBox.getValue());
    }

    void runAnimation()
    {
        this.window.canvas.animate();
    }

    void onActivate()
    {
        this.window = new NeuralTreeWindow(this);
        this.generator = new SimGenerator(&this.onGeneratorPoll, &this.onGeneratorSuccess);
        this.window.controlBox.connectGenerateClicked((ControlBox box) => this.generateSim());
        this.window.controlBox.connectRunClicked((ControlBox box) => this.runAnimation());
        this.window.present();
        this.generateSim();
    }
}
