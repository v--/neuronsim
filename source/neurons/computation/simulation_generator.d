module neurons.computation.simulation_generator;

import gtk.Main;
import glib.Timeout;

import std.concurrency: Tid, thisTid, spawn, send, receiveTimeout;

import neurons.computation.neural_tree_simulation_wrapper;
import neurons.computation.neural_tree_simulation;
import neurons.computation.parameter_set;

import core.time;

void work(Tid returnTid, immutable ParameterSet[] paramSets)
{
    immutable newTree = simulateTree(paramSets);
    send(returnTid, newTree);
}

class SimulationGenerator
{
    enum POLL_INTERVAL = 100;
    enum POLL_DURATION = 10;

    private
    {
        Tid worker;
        Timeout timeout;
        NeuralTreeSimulationWrapper treeWrapper;

        void delegate() onPoll;
        void delegate(NeuralTreeSimulationWrapper) onSuccess;
    }

    this(void delegate() onPoll, void delegate(NeuralTreeSimulationWrapper) onSuccess)
    {
        this.onPoll = onPoll;
        this.onSuccess = onSuccess;
    }

    void onMessage(immutable NeuralTreeSimulation tree)
    {
        treeWrapper = new NeuralTreeSimulationWrapper(tree);
        onSuccess(treeWrapper);
    }

    void generate(immutable ParameterSet[] paramSets)
    {
        if (treeWrapper !is null)
            treeWrapper.tree.destroy();

        treeWrapper.destroy();
        treeWrapper = null;

        worker = spawn(&work, thisTid(), paramSets);
        timeout = new Timeout(POLL_INTERVAL, {
            onPoll();
            return !receiveTimeout(dur!"msecs"(POLL_DURATION), &onMessage);
        });
    }
}
