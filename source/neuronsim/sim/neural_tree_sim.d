module neuronsim.sim.neural_tree_sim;

import neuronsim.sim.parameter_set;
import neuronsim.sim.sim_config;
import neuronsim.sim.impulse_sim;

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

immutable class NeuralTreeSim
{
    ParameterSet params;
    ImpulseSim impulse;
    NeuralTreeSim[] children;
    size_t depth;

    private this(immutable ParameterSet params, immutable ImpulseSim impulse, immutable NeuralTreeSim[] children, size_t depth)
    {
        this.params = params;
        this.impulse = impulse;
        this.children = children;
        this.depth = depth;
    }
}

immutable(NeuralTreeSim) simulateTree(immutable SimConfig config, size_t depth = 0)
{
    immutable params = config.paramSets[0];

    immutable(NeuralTreeSim)[] children;
    immutable ImpulseSim impulse = depth > 0 ? simulateImpulse(params, config.initialVoltage) : null;
    immutable endVoltage = impulse is null ? config.initialVoltage : impulse.maxEndpointVoltage;

    if (depth < config.treeDepth)
        foreach (i; 0..TREE_ARITY)
        {
            immutable step = countfullNaryTreeNodes(TREE_ARITY, config.treeDepth - depth - 1);
            immutable start = 1 + step * i;
            immutable end = 1 + step * (i + 1);
            immutable newConfig = new immutable SimConfig(config.paramSets[start..end], endVoltage, config.treeDepth);
            children ~= simulateTree(newConfig, depth + 1);
        }

    return new immutable NeuralTreeSim(params, impulse, children.idup(), depth);
}
