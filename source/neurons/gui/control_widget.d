module neurons.gui.control_widget;

import std.string : format;

import gtk.Box;
import gtk.Paned;
import gtk.Label;
import gtk.ToggleButton;
import gtk.CheckButton;
import gtk.Scale;
import gtk.Separator;

import neurons.computation.parameter;

class ControlWidget : Box
{
    Parameter parameter;

    private
    {
        Paned paned;
        Label label;
        CheckButton check;
        Scale scale;
        Separator separator;

        void onRandomizeToggled(ToggleButton button)
        {
            scale.setSensitive(!button.getActive());
        }
    }

    this(Parameter parameter)
    {
        super(Orientation.VERTICAL, 0);
        this.parameter = parameter;

        separator = new Separator(Orientation.HORIZONTAL);
        separator.setMarginBottom(10);
        add(separator);

        paned = new Paned(Orientation.HORIZONTAL);
        add(paned);

        label = new Label("%s (%s)".format(parameter.name, parameter.unit));
        label.setXalign(0);
        paned.pack1(label, true, false);

        check = new CheckButton("Randomize");
        check.setActive(true);
        check.addOnToggled(&onRandomizeToggled);
        paned.pack2(check, false, false);

        scale = new Scale(Orientation.HORIZONTAL, parameter.min, parameter.max, (parameter.max - parameter.min) / 100);
        scale.addMark(parameter.mode, GtkPositionType.BOTTOM, "%.2f (mode)".format(parameter.mode));
        scale.addMark(parameter.min, GtkPositionType.BOTTOM, "%.2f".format(parameter.min));
        scale.addMark(parameter.max, GtkPositionType.BOTTOM, "%.2f".format(parameter.max));
        scale.setValue(parameter.mode);
        scale.setSensitive(false);
        add(scale);
    }

    double getValue()
    {
        if (check.getActive())
            return parameter.simulateTriangular();

        return scale.getValue();
    }

    override void setSensitive(bool sensitive)
    {
        check.setSensitive(sensitive);
        label.setSensitive(sensitive);

        if (sensitive)
            scale.setSensitive(!check.getActive());
        else
            scale.setSensitive(false);
    }
}
