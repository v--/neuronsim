module neurons.computation.simulation_generator;

import gtk.Main;
import glib.Timeout;

import std.stdio: stderr;
import std.concurrency: Tid, thisTid, spawn, send, receiveTimeout;

import neurons.computation.mutable_simulation_wrapper;
import neurons.computation.neural_tree_simulation;
import neurons.computation.parameter_set;
import neurons.computation.simulation_config;

import core.time;

void work(Tid returnTid, immutable SimulationConfig config)
{
    try
    {
        immutable tree = simulateTree(config);
        send(returnTid, tree);
    }
    catch (Throwable err)
    {
        stderr.write(err);
        send(returnTid, cast(immutable NeuralTreeSimulation)null);
    }
}

class SimulationGenerator
{
    enum POLL_INTERVAL = 100;
    enum POLL_DURATION = 10;

    private
    {
        Tid worker;
        Timeout timeout;
        MutableSimulationWrapper treeWrapper;

        void delegate() onPoll;
        void delegate(MutableSimulationWrapper) onSuccess;
    }

    this(void delegate() onPoll, void delegate(MutableSimulationWrapper) onSuccess)
    {
        this.onPoll = onPoll;
        this.onSuccess = onSuccess;
    }

    void onMessage(immutable NeuralTreeSimulation tree)
    {
        treeWrapper = new MutableSimulationWrapper(treeWrapper.config, tree);
        onSuccess(treeWrapper);
    }

    void generate(immutable SimulationConfig config)
    {
        treeWrapper = new MutableSimulationWrapper(config, null);

        worker = spawn(&work, thisTid(), config);
        timeout = new Timeout(POLL_INTERVAL, {
            onPoll();
            return !receiveTimeout(dur!"msecs"(POLL_DURATION), &onMessage);
        });
    }
}
