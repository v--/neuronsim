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
        bool allowRandomization;

        void onRandomizeToggled(ToggleButton button)
        {
            scale.setSensitive(!button.getActive());
        }
    }

    this(Parameter parameter, bool allowRandomization = true)
    {
        import std.math : isNaN;

        super(Orientation.VERTICAL, 0);
        this.parameter = parameter;
        allowRandomization = allowRandomization;

        separator = new Separator(Orientation.HORIZONTAL);
        separator.setMarginBottom(10);
        add(separator);

        paned = new Paned(Orientation.HORIZONTAL);
        add(paned);

        immutable labelText = parameter.unit is null ? parameter.name : "%s (%s)".format(parameter.name, parameter.unit);
        label = new Label(labelText);
        label.setXalign(0);
        paned.pack1(label, true, false);

        check = new CheckButton("Randomize");
        check.setActive(allowRandomization);
        check.addOnToggled(&onRandomizeToggled);

        if (allowRandomization)
            paned.pack2(check, false, false);

        immutable step = isNaN(parameter.step) ? (parameter.max - parameter.min) / 100 : parameter.step;
        scale = new Scale(Orientation.HORIZONTAL, parameter.min, parameter.max, step);

        if (allowRandomization)
            scale.addMark(parameter.mode, GtkPositionType.BOTTOM, "%g (mode)".format(parameter.mode));

        scale.addMark(parameter.min, GtkPositionType.BOTTOM, "%g".format(parameter.min));
        scale.addMark(parameter.max, GtkPositionType.BOTTOM, "%g".format(parameter.max));
        scale.setValue(parameter.mode);
        scale.setSensitive(!allowRandomization);
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
