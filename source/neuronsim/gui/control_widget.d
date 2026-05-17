module neuronsim.gui.control_widget;

import std.string : format;

import gtk.adjustment : Adjustment;
import gtk.box : Box;
import gtk.check_button : CheckButton;
import gtk.label : Label;
import gtk.paned : Paned;
import gtk.scale : Scale;
import gtk.separator : Separator;
import gtk.toggle_button : ToggleButton;
import gtk.types : Align, Orientation, PositionType;

import neuronsim.sim.parameter;

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

        void onRandomizeToggled(CheckButton button)
        {
            this.scale.setSensitive(!button.getActive());
        }
    }

    this(Parameter parameter, bool allowRandomization = true)
    {
        import std.math : isNaN;

        super(Orientation.Vertical, 0);
        this.parameter = parameter;
        this.allowRandomization = allowRandomization;

        this.separator = new Separator(Orientation.Horizontal);
        this.separator.setMarginBottom(10);
        this.append(this.separator);

        this.paned = new Paned(Orientation.Horizontal);
        this.append(this.paned);

        immutable labelText = this.parameter.unit is null ? this.parameter.name : "%s (%s)".format(this.parameter.name, this.parameter.unit);
        this.label = new Label(labelText);
        this.label.setXalign(0);
        this.paned.startChild(this.label);

        this.check = new CheckButton();
        this.check.setLabel("Randomize");
        this.check.setActive(this.allowRandomization);

        if (this.allowRandomization)
        {
            this.check.connectToggled(&this.onRandomizeToggled);
            this.check.setHalign(Align.End);
            this.paned.endChild(this.check);
        }

        immutable step = isNaN(this.parameter.step) ? (this.parameter.max - this.parameter.min) / 100 : this.parameter.step;
        auto adjustment = new Adjustment(this.parameter.mode, this.parameter.min, this.parameter.max, step, -1, -1);
        this.scale = new Scale(Orientation.Horizontal, adjustment);

        if (this.allowRandomization)
            this.scale.addMark(this.parameter.mode, PositionType.Bottom, "%g (mode)".format(this.parameter.mode));

        this.scale.addMark(this.parameter.min, PositionType.Bottom, "%g".format(this.parameter.min));
        this.scale.addMark(this.parameter.max, PositionType.Bottom, "%g".format(this.parameter.max));
        this.scale.setValue(this.parameter.mode);
        this.scale.setSensitive(!this.allowRandomization);
        this.append(this.scale);
    }

    double getValue()
    {
        if (this.check.getActive())
            return this.parameter.simulateTriangular();

        return this.scale.getValue();
    }

    override void setSensitive(bool sensitive)
    {
        this.check.setSensitive(sensitive);
        this.label.setSensitive(sensitive);

        if (sensitive)
            this.scale.setSensitive(!this.check.getActive());
        else
            this.scale.setSensitive(false);
    }
}
