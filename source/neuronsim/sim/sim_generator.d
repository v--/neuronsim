module neuronsim.sim.sim_generator;

import glib.global : timeoutAdd;
import glib.source : Source;
import glib.types : PRIORITY_DEFAULT;
import std.concurrency: Tid, thisTid, spawn, send, receiveTimeout;
import std.stdio: stderr;

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
        uint timeoutSourceId;
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
        this.treeWrapper = new MutableSimWrapper(this.treeWrapper.config, tree);
        onSuccess(this.treeWrapper);
    }

    void generate(immutable SimConfig config)
    {
        this.treeWrapper = new MutableSimWrapper(config, null);
        this.worker = spawn(&work, thisTid(), config);

        if (this.timeoutSourceId > 0)
            Source.remove(this.timeoutSourceId);

        this.timeoutSourceId = timeoutAdd(PRIORITY_DEFAULT, POLL_INTERVAL, {
            this.onPoll();
            return !receiveTimeout(dur!"msecs"(POLL_DURATION), &this.onMessage);
        });
    }
}
