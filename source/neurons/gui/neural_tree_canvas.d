module neurons.gui.neural_tree_canvas;

import gtk.DrawingArea;
import gtk.Widget;
import glib.Timeout;
import cairo.Context;
import cairo.Pattern;

import neurons.computation.parameter_set;
import neurons.computation.impulse_simulation;
import neurons.computation.simulation_config;
import neurons.computation.neural_tree_simulation;
import neurons.computation.mutable_simulation_wrapper;

class NeuralTreeCanvas : DrawingArea
{
    enum FPS = 1000 / 30;
    enum MIN_SIZE = 600;
    enum NEURON_BODY_RADIUS = 5;
    enum TOTAL_STEPS = 50;

    private
    {
        MutableSimulationWrapper wrapper;
        size_t animationStep;
        Timeout timeout;

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
            return (1 - abs(voltage) / maxVoltage) ^^ 3;
        }

        bool onRender()
        {
            queueDraw();
            animationStep += 1;
            return animationStep < wrapper.config.treeDepth * TOTAL_STEPS;
        }

        void drawTail(Scoped!Context* context, double density, double colorIntensity, size_t centerX, size_t centerY)
        {
            import std.math : PI;
            context.setSourceRgb(1, colorIntensity, 1);
            context.arc(centerX, centerY, density * NEURON_BODY_RADIUS, 0, 2 * PI);
            context.fill();
        }

        void drawAxon(Scoped!Context* context, double density, immutable ImpulseSimulation impulse, immutable ParameterSet params, double proportion, size_t startX, size_t startY, size_t endX, size_t endY)
        {
            import std.math : PI;
            immutable voltageDistribution = impulse.getVoltageDistributionAt(proportion);

            auto pattern = Pattern.createLinear(startX, startY, endX, endY);

            foreach (i, voltage; voltageDistribution)
            {
                immutable offset = cast(double)i / voltageDistribution.length;
                immutable intensity = getColorIntensity(voltage);
                pattern.addColorStopRgb(offset, 1, intensity, 1);
            }

            context.setSource(pattern);
            context.setLineWidth(density * params.axonalRadius / 100);
            context.moveTo(startX, startY);
            context.lineTo(endX, endY);
            context.stroke();
        }

        void drawTree(Scoped!Context* context, double density, immutable NeuralTreeSimulation tree, double cumProportion, double parentAngle, size_t centerX, size_t centerY)
        {
            import std.conv : to;
            import std.math : PI, sin, cos;
            import std.algorithm : min, max;

            immutable proportion = cast(double)animationStep / TOTAL_STEPS;
            immutable newCumProportion = cumProportion + (tree.impulse is null ? 0 : tree.impulse.endProportion);
            immutable renderProportion = min(max(proportion - cumProportion, 0), 1);

            immutable length = to!size_t(density * tree.params.axonalLength * (MIN_SIZE - 25) / (3.00 /* 3cm is the max axonal length */ * 2 * wrapper.config.treeDepth));
            immutable endX = to!size_t(centerX + length * cos(parentAngle));
            immutable endY = to!size_t(centerY + length * sin(parentAngle));

            drawAxon(context, density, tree.impulse, tree.params, renderProportion, centerX, centerY, endX, endY);

            immutable childRotation = 3 * PI / (TREE_ARITY * (2 * tree.depth + 1));

            foreach (i, child; tree.children)
            {
                immutable angle = (parentAngle + (cast(int)i - 1) * childRotation) % (2 * PI);
                drawTree(context, density, child, newCumProportion, angle, endX, endY);
            }

            immutable voltageDistribution = tree.impulse.getVoltageDistributionAt(renderProportion);
            immutable colorIntensity = getColorIntensity(voltageDistribution[$ - 1]);
            drawTail(context, density, colorIntensity, endX, endY);
        }

        void drawRoot(Scoped!Context* context, double density, immutable NeuralTreeSimulation tree, size_t centerX, size_t centerY)
        {
            import std.math : PI;
            import std.algorithm : min;

            immutable renderProportion = min(cast(double)animationStep / TOTAL_STEPS, 1);
            immutable childRotation = 2 * PI / TREE_ARITY;

            foreach (i, child; tree.children)
            {
                immutable angle = ((cast(int)i - 1) * childRotation) % (2 * PI);
                drawTree(context, density, child, 0, angle, centerX, centerY);
            }

            immutable voltageDistribution = tree.children[0].impulse.getVoltageDistributionAt(renderProportion);
            immutable colorIntensity = animationStep == 0 ? 1 : getColorIntensity(voltageDistribution[0]);
            drawTail(context, density, colorIntensity, centerX, centerY);
        }

        void drawFrame(Scoped!Context* context)
        {
            import std.algorithm : min;

            context.setSourceRgb(0, 0, 0);
            context.paint();

            if (wrapper is null)
                return;

            GtkAllocation size;
            getAllocation(size);

            immutable centerX = size.x + size.width / 2;
            immutable centerY = size.y + size.height / 2;
            immutable density = 0.9 * cast(double)min(size.width, size.height) / MIN_SIZE;

            drawRoot(context, density, wrapper.tree, centerX, centerY);
        }

        bool onDraw(Scoped!Context context, Widget)
        {
            drawFrame(&context);
            return true;
        }
    }

    this()
    {
        super();
        addOnDraw(&onDraw);
    }

    void updateSimulationWrapper(MutableSimulationWrapper treeWrapper)
    {
        if (timeout)
            timeout.stop();

        wrapper = treeWrapper;
        animationStep = 0;
        queueDraw();
    }

    void animate()
    {
        if (wrapper is null)
            return;

        if (timeout)
            timeout.stop();

        animationStep = 0;
        timeout = new Timeout(FPS, &onRender);
    }
}
