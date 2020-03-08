module neurons.computation.mutable_simulation_wrapper;

import neurons.computation.neural_tree_simulation;
import neurons.computation.simulation_config;

class MutableSimulationWrapper
{
    immutable SimulationConfig config;
    immutable NeuralTreeSimulation tree;

    this(immutable SimulationConfig config, immutable NeuralTreeSimulation tree)
    {
        this.config = config;
        this.tree = tree;
    }
}
