module neuronsim.gui.control_box;

import std.traits : getUDAs, getSymbolsByUDA, fullyQualifiedName;

import gtk.box : Box;
import gtk.button : Button;
import gtk.types : Orientation;

import neuronsim.gui.control_widget;
import neuronsim.sim.impulse_sim;
import neuronsim.sim.neural_tree_sim;
import neuronsim.sim.parameter;
import neuronsim.sim.parameter_set;
import neuronsim.sim.sim_config;

private alias parameterSetMembers = getSymbolsByUDA!(ParameterSet, Parameter);

class ControlBox : Box
{
    enum TREE_DEPTH_PARAMETER = Parameter("Tree depth", null, 4, 2, 5, 1);
    enum INITIAL_VOLTAGE_PARAMETER = Parameter("Initial voltage at root", "mV", 300.00, 200.00, 400.00);

    private
    {
        Button generateButton;
        Button runButton;
        ControlWidget treeDepthControl;
        ControlWidget initialVoltageControl;
        ControlWidget[parameterSetMembers.length] controls;
    }

    this()
    {
        super(Orientation.Vertical, 15);
        this.margin(15);

        this.runButton = new Button();
        this.runButton.setLabel("Run simulation on generated tree");
        this.append(this.runButton);

        this.generateButton = new Button();
        this.generateButton.setLabel("Generate new tree");
        this.append(this.generateButton);

        this.treeDepthControl = new ControlWidget(TREE_DEPTH_PARAMETER, false);
        this.append(this.treeDepthControl);

        this.initialVoltageControl = new ControlWidget(INITIAL_VOLTAGE_PARAMETER, false);
        this.append(this.initialVoltageControl);

        static foreach (i, member; parameterSetMembers)
        {
            {
                auto parameter = getUDAs!(member, Parameter)[0];
                auto widget = new ControlWidget(parameter);
                this.append(widget);
                controls[i] = widget;
            }
        }
    }

    ulong connectGenerateClicked(void delegate(ControlBox) dlg)
    {
        return this.generateButton.connectClicked((Button btn) => dlg(this));
    }

    ulong connectRunClicked(void delegate(ControlBox) dlg)
    {
        return this.runButton.connectClicked((Button btn) => dlg(this));
    }

    ParameterSet getParamSet()
    {
        ParameterSet result;

        static foreach (i, member; parameterSetMembers)
            __traits(getMember, result, __traits(identifier, member)) = controls[i].getValue();

        return result;
    }

    immutable(ParameterSet[]) getParamSets(size_t count)
    {
        import std.range : front, popFront, empty, generate, take;
        import std.array : array;

        return generate(&this.getParamSet)
            .take(count)
            .array()
            .idup();
    }

    double getInitialVoltage()
    {
        return this.initialVoltageControl.getValue();
    }

    size_t getTreeDepth()
    {
        import std.conv : to;
        return to!size_t(this.treeDepthControl.getValue());
    }

    immutable(SimConfig) getValue()
    {
        auto depth = getTreeDepth();

        return new immutable SimConfig(
            this.getParamSets(countFullNaryTreeNodes(TREE_ARITY, depth)),
            this.getInitialVoltage(),
            depth
        );
    }

    void setOverallSensitive(bool sensitive)
    {
        this.generateButton.setSensitive(sensitive);
        this.runButton.setSensitive(sensitive);

        this.treeDepthControl.setSensitive(sensitive);
        this.initialVoltageControl.setSensitive(sensitive);

        static foreach (i, member; parameterSetMembers)
            controls[i].setSensitive(sensitive);
    }

    void setGenerateButtonSensitive(bool sensitive)
    {
        this.generateButton.setSensitive(sensitive);
    }
}
