module neurons.computation.neural_tree_simulation_wrapper;

import neurons.computation.neural_tree_simulation;

/// A mutable wrapper around an otherwise immutable class
class NeuralTreeSimulationWrapper
{
    immutable NeuralTreeSimulation tree;

    this(immutable NeuralTreeSimulation tree)
    {
        this.tree = tree;
    }
}
