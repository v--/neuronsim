module neuronsim.sim.sim_generator;

import gtk.Main;
import glib.Timeout;

import std.stdio: stderr;
import std.concurrency: Tid, thisTid, spawn, send, receiveTimeout;

import neuronsim.sim.mutable_sim_wrapper;
import neuronsim.sim.neural_tree_sim;
import neuronsim.sim.parameter_set;
import neuronsim.sim.sim_config;

import core.time;

void work(Tid returnTid, immutable SimConfig config)
{
    try
    {
        immutable tree = simulateTree(config);
        send(returnTid, tree);
    }
    catch (Throwable err)
    {
        stderr.write(err);
        send(returnTid, cast(immutable NeuralTreeSim)null);
    }
}

class SimGenerator
{
    enum POLL_INTERVAL = 100;
    enum POLL_DURATION = 10;

    private
    {
        Tid worker;
        Timeout timeout;
        MutableSimWrapper treeWrapper;

        void delegate() onPoll;
        void delegate(MutableSimWrapper) onSuccess;
    }

    this(void delegate() onPoll, void delegate(MutableSimWrapper) onSuccess)
    {
        this.onPoll = onPoll;
        this.onSuccess = onSuccess;
    }

    void onMessage(immutable NeuralTreeSim tree)
    {
        treeWrapper = new MutableSimWrapper(treeWrapper.config, tree);
        onSuccess(treeWrapper);
    }

    void generate(immutable SimConfig config)
    {
        treeWrapper = new MutableSimWrapper(config, null);

        worker = spawn(&work, thisTid(), config);
        timeout = new Timeout(POLL_INTERVAL, {
            onPoll();
            return !receiveTimeout(dur!"msecs"(POLL_DURATION), &onMessage);
        });
    }
}
