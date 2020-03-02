module neurons.computation.neural_tree_simulation;

import neurons.computation.parameter_set;
import neurons.computation.impulse_simulation;

enum TREE_DEPTH = 3;
enum TREE_ARITY = 3;
enum TREE_SIZE = TREE_DEPTH ^^ TREE_ARITY;

immutable class NeuralTreeSimulation
{
    ParameterSet params;
    ImpulseSimulation impulse;
    NeuralTreeSimulation[] children;
    size_t depth;

    private this(immutable ParameterSet params, immutable ImpulseSimulation impulse, immutable NeuralTreeSimulation[] children, size_t depth)
    {
        this.params = params;
        this.impulse = impulse;
        this.children = children;
        this.depth = depth;
    }
}

immutable(NeuralTreeSimulation) simulateTree(immutable ParameterSet[] paramSets, double initialVoltage = double.nan, size_t depth = 0)
{
    import std.math : isNaN;
    immutable params = paramSets[0];

    if (isNaN(initialVoltage))
        initialVoltage = params.initialVoltage;

    immutable(NeuralTreeSimulation)[] children;
    immutable ImpulseSimulation impulse = depth > 0 ? simulateImpulse(params, initialVoltage) : null;
    immutable endVoltage = impulse is null ? initialVoltage : impulse.maxEndpointVoltage;

    if (depth < TREE_DEPTH)
        foreach (i; 0..TREE_ARITY)
            children ~= simulateTree(paramSets[TREE_ARITY ^^ (TREE_DEPTH - depth - 1) * i..$], endVoltage, depth + 1);

    return new immutable NeuralTreeSimulation(params, impulse, children.idup(), depth);
}
