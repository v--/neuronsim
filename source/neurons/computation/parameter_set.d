module neurons.computation.parameter_set;

import neurons.computation.parameter : Parameter;

struct ParameterSet
{
    @Parameter("Temperature", "C°", 18.50, 15.00, 20.00)
    double temperature;

    @Parameter("Axonal length", "cm", 2.50, 2.00, 3.00)
    double axonalLength;

    @Parameter("Axonal radius", "μm", 238.00, 200.00, 300.00)
    double axonalRadius;

    @Parameter("Cytoplasm resistivity", "ohm-m", 35.40, 20.00, 50.00)
    double cytoplasmResistivity;

    @Parameter("Square unit capacitance", "μF / cm^2", 0.91, 0.80, 1.50)
    double squareUnitCapacitance;

    @Parameter("Max sodium conductance", "mS / cm^2", 120.00, 65.00, 260.00)
    double maxSodiumConductance;

    @Parameter("Max potassium conductance", "mS / cm^2", 34.00, 26.00, 49.00)
    double maxPotassiumConductance;

    @Parameter("Max leakage conductance", "mS / cm^2", 0.26, 0.13, 0.50)
    double maxLeakageConductance;

    @Parameter("Sodium diffusion potential", "mV", 109.00, 95.00, 119.00)
    double sodiumDiffusionPotential;

    @Parameter("Potassium diffusion potential", "mV", -11.00, -14.00, -9.00)
    double potassiumDiffusionPotential;

    @Parameter("Leakage diffusion potential", "mV", 11.00, 4.00, 22.00)
    double leakageDiffusionPotential;
}
