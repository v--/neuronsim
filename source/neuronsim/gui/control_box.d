module neuronsim.gui.control_box;

import std.traits : fullyQualifiedName, getUDAs, getSymbolsByUDA;

import gtk.Box;
import gtk.Button;

import neuronsim.sim.neural_tree_sim;
import neuronsim.sim.impulse_sim;
import neuronsim.sim.sim_config;
import neuronsim.sim.parameter_set;
import neuronsim.sim.parameter;

import neuronsim.gui.control_widget;

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
        super(Orientation.VERTICAL, 15);
        setMarginRight(15);
        setMarginBottom(15);
        setMarginLeft(15);
        setMarginTop(15);

        runButton = new Button("Run simulation on generated tree");
        add(runButton);

        generateButton = new Button("Generate new tree");
        add(generateButton);

        treeDepthControl = new ControlWidget(TREE_DEPTH_PARAMETER, false);
        add(treeDepthControl);

        initialVoltageControl = new ControlWidget(INITIAL_VOLTAGE_PARAMETER, false);
        add(initialVoltageControl);

        static foreach (i, member; parameterSetMembers)
        {
            {
                auto parameter = getUDAs!(member, Parameter)[0];
                auto widget = new ControlWidget(parameter);
                add(widget);
                controls[i] = widget;
            }
        }
    }

    void addOnGenerateClicked(void delegate(ControlBox) dlg)
    {
        generateButton.addOnClicked(btn => dlg(this));
    }

    void addOnRunClicked(void delegate(ControlBox) dlg)
    {
        runButton.addOnClicked(btn => dlg(this));
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

        return generate(&getParamSet)
            .take(count)
            .array()
            .idup();
    }

    double getInitialVoltage()
    {
        return initialVoltageControl.getValue();
    }

    size_t getTreeDepth()
    {
        import std.conv : to;
        return to!size_t(treeDepthControl.getValue());
    }

    immutable(SimConfig) getValue()
    {
        auto depth = getTreeDepth();

        return new immutable SimConfig(
            getParamSets(countFullNaryTreeNodes(TREE_ARITY, depth)),
            getInitialVoltage(),
            depth
        );
    }

    void setOverallSensitive(bool sensitive)
    {
        generateButton.setSensitive(sensitive);
        runButton.setSensitive(sensitive);

        treeDepthControl.setSensitive(sensitive);
        initialVoltageControl.setSensitive(sensitive);

        static foreach (i, member; parameterSetMembers)
            controls[i].setSensitive(sensitive);
    }

    void setGenerateButtonSensitive(bool sensitive)
    {
        generateButton.setSensitive(sensitive);
    }
}
