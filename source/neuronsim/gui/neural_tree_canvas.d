module neuronsim.gui.neural_tree_canvas;

import std.typecons : scoped;

import cairo.context : Context;
import cairo.global : patternCreateLinear;
import glib.global : timeoutAdd;
import glib.source : Source;
import glib.types : PRIORITY_DEFAULT;
import gtk.drawing_area : DrawingArea;
import gtk.types : Allocation;

import neuronsim.sim.parameter_set;
import neuronsim.sim.impulse_sim;
import neuronsim.sim.sim_config;
import neuronsim.sim.neural_tree_sim;
import neuronsim.sim.mutable_sim_wrapper;

class NeuralTreeCanvas : DrawingArea
{
    enum FPS = 1000 / 30;
    enum MIN_SIZE = 600;
    enum NEURON_BODY_RADIUS = 5;
    enum TOTAL_STEPS = 50;

    private
    {
        MutableSimWrapper wrapper;
        size_t animationStep;
        uint timeoutSourceId;

        double maxVoltage()
        {
            if (this.wrapper is null)
                return 0;

            return this.wrapper.tree.children[0].impulse.maxVoltage;
        }

        // We need a function that decreases slow enough
        double getColorIntensity(double voltage)
        {
            import std.math : abs;
            return (1 - abs(voltage) / this.maxVoltage) ^^ 3;
        }

        bool requestRedraw()
        {
            this.queueDraw();
            this.animationStep += 1;
            return this.animationStep < this.wrapper.config.treeDepth * TOTAL_STEPS;
        }

        void drawTail(Context* context, double density, double colorIntensity, size_t centerX, size_t centerY)
        {
            import std.math : PI;
            context.setSourceRgb(1, colorIntensity, 1);
            context.arc(centerX, centerY, density * NEURON_BODY_RADIUS, 0, 2 * PI);
            context.fill();
        }

        void drawAxon(Context* context, double density, immutable ImpulseSim impulse, immutable ParameterSet params, double proportion, size_t startX, size_t startY, size_t endX, size_t endY)
        {
            import std.math : PI;
            immutable voltageDistribution = impulse.getVoltageDistributionAt(proportion);

            auto pattern = patternCreateLinear(startX, startY, endX, endY);

            foreach (i, voltage; voltageDistribution)
            {
                immutable offset = cast(double)i / voltageDistribution.length;
                immutable intensity = this.getColorIntensity(voltage);
                pattern.addColorStopRgb(offset, 1, intensity, 1);
            }

            context.setSource(pattern);
            context.setLineWidth(density * params.axonalRadius / 100);
            context.moveTo(startX, startY);
            context.lineTo(endX, endY);
            context.stroke();
        }

        void drawTree(Context* context, double density, immutable NeuralTreeSim tree, double cumProportion, double parentAngle, size_t centerX, size_t centerY)
        {
            import std.conv : to;
            import std.math : PI, sin, cos;
            import std.algorithm : min, max;

            immutable proportion = cast(double)this.animationStep / TOTAL_STEPS;
            immutable newCumProportion = cumProportion + (tree.impulse is null ? 0 : tree.impulse.endProportion);
            immutable renderProportion = min(max(proportion - cumProportion, 0), 1);

            immutable length = to!size_t(density * tree.params.axonalLength * (MIN_SIZE - 25) / (3.00 /* 3cm is the max axonal length */ * 2 * this.wrapper.config.treeDepth));
            immutable endX = to!size_t(centerX + length * cos(parentAngle));
            immutable endY = to!size_t(centerY + length * sin(parentAngle));

            this.drawAxon(context, density, tree.impulse, tree.params, renderProportion, centerX, centerY, endX, endY);

            immutable childRotation = 3 * PI / (TREE_ARITY * (2 * tree.depth + 1));

            foreach (i, child; tree.children)
            {
                immutable angle = (parentAngle + (cast(int)i - 1) * childRotation) % (2 * PI);
                this.drawTree(context, density, child, newCumProportion, angle, endX, endY);
            }

            immutable voltageDistribution = tree.impulse.getVoltageDistributionAt(renderProportion);
            immutable colorIntensity = this.getColorIntensity(voltageDistribution[$ - 1]);
            this.drawTail(context, density, colorIntensity, endX, endY);
        }

        void drawRoot(Context* context, double density, immutable NeuralTreeSim tree, size_t centerX, size_t centerY)
        {
            import std.math : PI;
            import std.algorithm : min;

            immutable renderProportion = min(cast(double)this.animationStep / TOTAL_STEPS, 1);
            immutable childRotation = 2 * PI / TREE_ARITY;

            foreach (i, child; tree.children)
            {
                immutable angle = ((cast(int)i - 1) * childRotation) % (2 * PI);
                this.drawTree(context, density, child, 0, angle, centerX, centerY);
            }

            immutable voltageDistribution = tree.children[0].impulse.getVoltageDistributionAt(renderProportion);
            immutable colorIntensity = this.animationStep == 0 ? 1 : this.getColorIntensity(voltageDistribution[0]);
            this.drawTail(context, density, colorIntensity, centerX, centerY);
        }

        void drawFrame(Context* context)
        {
            import std.algorithm : min;

            context.setSourceRgb(0, 0, 0);
            context.paint();

            if (this.wrapper is null)
                return;

            Allocation size;
            getAllocation(size);

            immutable centerX = size.x + size.width / 2;
            immutable centerY = size.y + size.height / 2;
            immutable density = 0.9 * cast(double)min(size.width, size.height) / MIN_SIZE;

            this.drawRoot(context, density, this.wrapper.tree, centerX, centerY);
        }

        void onDraw(DrawingArea, Context context, int, int)
        {
            this.drawFrame(&context);
        }
    }

    this()
    {
        super();
        this.setDrawFunc(&this.onDraw);
    }

    void updateSimWrapper(MutableSimWrapper treeWrapper)
    {
        if (this.timeoutSourceId > 0)
            Source.remove(this.timeoutSourceId);

        this.wrapper = treeWrapper;
        this.animationStep = 0;
        this.queueDraw();
    }

    void animate()
    {
        if (this.wrapper is null)
            return;

        if (this.timeoutSourceId > 0)
            Source.remove(this.timeoutSourceId);

        this.animationStep = 0;
        this.timeoutSourceId = timeoutAdd(PRIORITY_DEFAULT, FPS, &this.requestRedraw);
    }
}
