module helpers.logger;
import std.datetime: Clock;
import std.file: write, append, mkdirRecurse;
import std.string: format;
import events;

private
{
    string filename;

    void impulseLog(float[14] info)
    {
        auto line = "%(%.2f, %)\n".format(info);
        append(filename, line);
    }
}

shared static this()
{
    mkdirRecurse("results");
    filename = "results/%s.csv".format(Clock.currTime.toISOExtString);
    write(filename, "v0, vEnd, temp, tTotal, xTotal, a, rho, cap, gNa, gK, gL, vNa, vK, vL\n");
    subscribe!"impulseLog"(&impulseLog);
}
