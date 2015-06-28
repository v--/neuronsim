import std.typecons: Tuple;
import std.random: uniform;
import std.stdio;
import helpers;

alias Parameters = Tuple!(
    float, "xTotal",
    float, "a",
    float, "rho",
    float, "cap",
    float, "gNa",
    float, "gK",
    float, "gL",
    float, "vNa",
    float, "vK",
    float, "vL"
);

enum meanParams = Parameters(1.00, 2.38, 35.4, 0.91, 120.0, 34.0, 0.26, 109.0, -11.0, 11.0);
enum minParams  = Parameters(0.80, 1.00, 20.0, 0.80, 65.00, 26.0, 0.13, 95.00, -14.0, 4.00);
enum maxParams  = Parameters(1.40, 3.00, 50.0, 1.50, 260.0, 49.0, 0.50, 119.0, -9.00, 22.0);

Parameters randomParams() {
    Parameters params;

    foreach (key, ref param; params)
        param = uniform(minParams[key], maxParams[key]);

    return params;
}
