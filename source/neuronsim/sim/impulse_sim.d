module neuronsim.sim.impulse_sim;

import neuronsim.sim.parameter_set;

enum MAX_MOMENTS = 2500;
enum MAX_INDEX = MAX_MOMENTS - 1;
enum LENGTH_SUBDIVISION = 10;
enum DELTA_T = 1e-2;

immutable class ImpulseSim
{
    double minVoltage;
    double maxVoltage;
    double maxEndpointVoltage;

    private
    {
        double[LENGTH_SUBDIVISION][MAX_MOMENTS] impulse;
        size_t endIndex = MAX_INDEX;
    }

    private this(double[LENGTH_SUBDIVISION][MAX_MOMENTS] impulse, size_t endIndex, double minVoltage, double maxVoltage, double maxEndpointVoltage)
    {
        this.impulse = impulse;
        this.endIndex = endIndex;
        this.minVoltage = minVoltage;
        this.maxVoltage = maxVoltage;
        this.maxEndpointVoltage = maxEndpointVoltage;
    }

    double[LENGTH_SUBDIVISION] getVoltageDistributionAt(double proportion) immutable
    in (proportion >= 0 && proportion <= 1)
    body
    {
        import std.conv : to;
        return impulse[to!int(proportion * MAX_INDEX)];
    }

    double endProportion() immutable
    {
        return cast(double)endIndex / MAX_INDEX;
    }

    double initialVoltage() immutable
    {
        return this.impulse[0][0];
    }
}

private
{
    import std.math : exp;

    // These are coefficient functions with no obvious interpretation
    pure double sodiumOnA(double voltage)
    {
        if (voltage == 25)
            return 1;

        return 0.1 * (25 - voltage) / (exp((25 - voltage) / 10) - 1);
    }

    pure double sodiumOnB(double voltage)
    {
        return 4 * exp(-voltage / 18);
    }

    pure double sodiumOffA(double voltage)
    {
        return 0.08 * exp(-voltage / 20);
    }

    pure double sodiumOffB(double voltage)
    {
        return 1 / (exp((30 - voltage) / 10) + 1);
    }

    pure double potassiumOnA(double voltage)
    {
        if (voltage == 10)
            return 0.1;

        return 0.01 * (10 - voltage) / (exp((10 - voltage) / 10) - 1);
    }

    pure double potassiumOnB(double voltage)
    {
        return 0.125 * exp(-voltage / 80);
    }
}

immutable(ImpulseSim) simulateImpulse(immutable ParameterSet params, double initialVoltage)
{
    import std.math : floor, exp, sin, cos, PI;
    import std.algorithm : min;

    double[LENGTH_SUBDIVISION][MAX_MOMENTS] impulse;

    immutable tempFactor = 3 ^^ ((6.3 - params.temperature) / 10);
    immutable unitResistance = params.cytoplasmResistivity / (PI * params.axonalLength ^^ 2);
    immutable unitConductance = 2 * PI * params.axonalLength * params.squareUnitCapacitance;

    immutable deltaX = params.axonalLength / LENGTH_SUBDIVISION;

    double[LENGTH_SUBDIVISION + 2] voltage, sodiumOn, sodiumOff, potassiumOn;

    sodiumOn[] = sodiumOnA(0) / (sodiumOnA(0) + sodiumOnB(0));
    sodiumOff[] = sodiumOffA(0) / (sodiumOffA(0) + sodiumOffB(0));
    potassiumOn[] = potassiumOnA(0) / (potassiumOnA(0) + potassiumOnB(0));
    voltage[0..LENGTH_SUBDIVISION / 4] = initialVoltage;
    voltage[LENGTH_SUBDIVISION / 4..$] = 0;

    size_t endIndex;
    double minVoltage = 0;
    double maxVoltage = 0;
    double maxEndpointVoltage = 0;

    foreach (j; 0..impulse.length)
    {
        double minNewV = 0;
        double maxNewV = 0;

        impulse[j] = voltage[1..$ - 1].dup;

        double[LENGTH_SUBDIVISION + 2] newVoltage, newSodiumOn, newSodiumOff, newPotassiumOn;

        foreach (i, v; voltage)
        {
            newSodiumOn[i] = sodiumOn[i] + tempFactor * DELTA_T * (sodiumOnA(v) * (1 - sodiumOn[i]) - sodiumOnB(v) * sodiumOn[i]);
            newSodiumOff[i] = sodiumOff[i] + tempFactor * DELTA_T * (sodiumOffA(v) * (1 - sodiumOff[i]) - sodiumOffB(v) * sodiumOff[i]);
            newPotassiumOn[i] = potassiumOn[i] + tempFactor * DELTA_T * (potassiumOnA(v) * (1 - potassiumOn[i]) - potassiumOnB(v) * potassiumOn[i]);

            immutable transmembraneSodium = params.maxSodiumConductance * (v - params.sodiumDiffusionPotential) * sodiumOn[i] ^^ 3 * sodiumOff[i];
            immutable transmembranePotassium = params.maxPotassiumConductance * (v - params.potassiumDiffusionPotential)  * potassiumOn[i] ^^ 4;
            immutable transmembraneLeakage = params.maxLeakageConductance * (v - params.leakageDiffusionPotential);
            immutable transmembrane = 2 * PI * params.axonalLength * (transmembraneSodium + transmembranePotassium + transmembraneLeakage);

            if (i == 0 || i + 1 == voltage.length)
                newVoltage[i] = 0;
            else
                newVoltage[i] = v + DELTA_T / unitConductance * ((voltage[i + 1] - 2 * v + voltage[i - 1]) / (deltaX ^^ 2 * unitResistance) - transmembrane);

            if (voltage[i] > maxNewV)
                maxNewV = voltage[i];

            if (voltage[i] < minNewV)
                minNewV = voltage[i];
        }

        voltage = newVoltage;
        sodiumOn = newSodiumOn;
        sodiumOff = newSodiumOff;
        potassiumOn = newPotassiumOn;

        if (maxNewV > maxVoltage)
            maxVoltage = maxNewV;

        if (minNewV < minVoltage)
            minVoltage = minNewV;

        if (voltage[$ - 2] > maxEndpointVoltage)
        {
            maxEndpointVoltage = voltage[$ - 2];
            endIndex = j;
        }
    }

    return new immutable ImpulseSim(impulse, endIndex, minVoltage, maxVoltage, maxEndpointVoltage);
}
