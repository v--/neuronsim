module neuronsim.sim.sim_config;

import neuronsim.sim.parameter_set : ParameterSet;

immutable class SimConfig
{
    ParameterSet[] paramSets;
    double initialVoltage;
    size_t treeDepth;

    this(immutable(ParameterSet[]) paramSets, double initialVoltage, size_t treeDepth)
    {
        this.paramSets = paramSets;
        this.initialVoltage = initialVoltage;
        this.treeDepth = treeDepth;
    }
}
