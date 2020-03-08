module neuronsim.sim.mutable_sim_wrapper;

import neuronsim.sim.neural_tree_sim;
import neuronsim.sim.sim_config;

class MutableSimWrapper
{
    immutable SimConfig config;
    immutable NeuralTreeSim tree;

    this(immutable SimConfig config, immutable NeuralTreeSim tree)
    {
        this.config = config;
        this.tree = tree;
    }
}
