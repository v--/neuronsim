module neurons.computation.neural_tree_simulation;

import neurons.computation.parameter_set;
import neurons.computation.simulation_config;
import neurons.computation.impulse_simulation;

enum TREE_ARITY = 3;

size_t countfullNaryTreeNodes(size_t arity, size_t depth)
{
    if (depth == 0)
        return 1;

    return 1 + arity * countfullNaryTreeNodes(arity, depth - 1);
}

unittest
{
    assert(countfullNaryTreeNodes(1, 9) == 10);

    assert(countfullNaryTreeNodes(2, 0) == 1);
    assert(countfullNaryTreeNodes(2, 1) == 3);
    assert(countfullNaryTreeNodes(2, 2) == 7);

    assert(countfullNaryTreeNodes(3, 0) == 1);
    assert(countfullNaryTreeNodes(3, 1) == 4);
    assert(countfullNaryTreeNodes(3, 2) == 13);
}

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

immutable(NeuralTreeSimulation) simulateTree(immutable SimulationConfig config, size_t depth = 0)
{
    immutable params = config.paramSets[0];

    immutable(NeuralTreeSimulation)[] children;
    immutable ImpulseSimulation impulse = depth > 0 ? simulateImpulse(params, config.initialVoltage) : null;
    immutable endVoltage = impulse is null ? config.initialVoltage : impulse.maxEndpointVoltage;

    if (depth < config.treeDepth)
        foreach (i; 0..TREE_ARITY)
        {
            immutable step = countfullNaryTreeNodes(TREE_ARITY, config.treeDepth - depth - 1);
            immutable start = 1 + step * i;
            immutable end = 1 + step * (i + 1);
            immutable newConfig = new immutable SimulationConfig(config.paramSets[start..end], endVoltage, config.treeDepth);
            children ~= simulateTree(newConfig, depth + 1);
        }

    return new immutable NeuralTreeSimulation(params, impulse, children.idup(), depth);
}
