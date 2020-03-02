module neurons.gui.control_box;

import std.traits : fullyQualifiedName, getUDAs, getSymbolsByUDA;

import gtk.Box;
import gtk.Button;

import neurons.computation.impulse_simulation;
import neurons.computation.parameter_set;
import neurons.computation.parameter;

import neurons.gui.control_widget;

private alias parameterSetMembers = getSymbolsByUDA!(ParameterSet, Parameter);

class ControlBox : Box
{
    Button generateButton;
    Button runButton;
    ControlWidget[parameterSetMembers.length] controls;

    this()
    {
        super(Orientation.VERTICAL, 15);
        setMarginRight(15);
        setMarginBottom(15);
        setMarginLeft(15);
        setMarginTop(15);

        generateButton = new Button("Generate new tree");
        add(generateButton);

        runButton = new Button("Run simulation");
        add(runButton);

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

    ParameterSet getValue()
    {
        ParameterSet result;

        static foreach (i, member; parameterSetMembers)
            __traits(getMember, result, __traits(identifier, member)) = controls[i].getValue();

        return result;
    }

    override void setSensitive(bool sensitive)
    {
        generateButton.setSensitive(sensitive);
        runButton.setSensitive(sensitive);

        static foreach (i, member; parameterSetMembers)
            controls[i].setSensitive(sensitive);
    }
}
