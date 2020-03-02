module neurons.computation.impulse_simulation;

import neurons.computation.parameter_set;

enum MAX_MOMENTS = 2500;
enum MAX_INDEX = MAX_MOMENTS - 1;
enum LENGTH_SUBDIVISION = 10;
enum DELTA_T = 1e-2;

immutable class ImpulseSimulation
{
    float minVoltage;
    float maxVoltage;
    float maxEndpointVoltage;

    private
    {
        float[LENGTH_SUBDIVISION][MAX_MOMENTS] impulse;
        size_t endIndex = MAX_INDEX;
    }

    private this(float[LENGTH_SUBDIVISION][MAX_MOMENTS] impulse, size_t endIndex, float minVoltage, float maxVoltage, float maxEndpointVoltage)
    {
        this.impulse = impulse;
        this.endIndex = endIndex;
        this.minVoltage = minVoltage;
        this.maxVoltage = maxVoltage;
        this.maxEndpointVoltage = maxEndpointVoltage;
    }

    float[LENGTH_SUBDIVISION] getVoltageDistributionAt(float proportion) immutable
    in (proportion >= 0 && proportion <= 1)
    body
    {
        import std.conv : to;
        return impulse[to!int(proportion * MAX_INDEX)];
    }

    float endProportion() immutable
    {
        return cast(float)endIndex / MAX_INDEX;
    }

    float initialVoltage() immutable
    {
        return this.impulse[0][0];
    }
}

private
{
    import std.math : exp;

    // These are coefficient functions with no obvious interpretation
    pure float sodiumOnA(float voltage)
    {
        if (voltage == 25)
            return 1;

        return 0.1 * (25 - voltage) / (exp((25 - voltage) / 10) - 1);
    }

    pure float sodiumOnB(float voltage)
    {
        return 4 * exp(-voltage / 18);
    }

    pure float sodiumOffA(float voltage)
    {
        return 0.08 * exp(-voltage / 20);
    }

    pure float sodiumOffB(float voltage)
    {
        return 1 / (exp((30 - voltage) / 10) + 1);
    }

    pure float potassiumOnA(float voltage)
    {
        if (voltage == 10)
            return 0.1;

        return 0.01 * (10 - voltage) / (exp((10 - voltage) / 10) - 1);
    }

    pure float potassiumOnB(float voltage)
    {
        return 0.125 * exp(-voltage / 80);
    }
}

immutable(ImpulseSimulation) simulateImpulse(ParameterSet params, float initialVoltage)
{
    import std.math : floor, exp, sin, cos, PI;
    import std.algorithm : min;

    float[LENGTH_SUBDIVISION][MAX_MOMENTS] impulse;

    immutable tempFactor = 3 ^^ ((6.3 - params.temperature) / 10);
    immutable unitResistance = params.cytoplasmResistivity / (PI * params.axonalLength ^^ 2);
    immutable unitConductance = 2 * PI * params.axonalLength * params.squareUnitCapacitance;

    immutable deltaX = params.axonalLength / LENGTH_SUBDIVISION;

    float[LENGTH_SUBDIVISION + 2] voltage, sodiumOn, sodiumOff, potassiumOn;

    sodiumOn[] = sodiumOnA(0) / (sodiumOnA(0) + sodiumOnB(0));
    sodiumOff[] = sodiumOffA(0) / (sodiumOffA(0) + sodiumOffB(0));
    potassiumOn[] = potassiumOnA(0) / (potassiumOnA(0) + potassiumOnB(0));
    voltage[0..LENGTH_SUBDIVISION / 4] = initialVoltage;
    voltage[LENGTH_SUBDIVISION / 4..$] = 0;

    size_t endIndex;
    float minVoltage = 0;
    float maxVoltage = 0;
    float maxEndpointVoltage = 0;

    foreach (j; 0..impulse.length)
    {
        float minNewV = 0;
        float maxNewV = 0;

        impulse[j] = voltage[1..$ - 1].dup;

        float[LENGTH_SUBDIVISION + 2] newVoltage, newSodiumOn, newSodiumOff, newPotassiumOn;

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

    return new immutable ImpulseSimulation(impulse, endIndex, minVoltage, maxVoltage, maxEndpointVoltage);
}
