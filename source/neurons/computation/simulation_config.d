module neurons.computation.simulation_config;

import neurons.computation.parameter_set : ParameterSet;

immutable class SimulationConfig
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
