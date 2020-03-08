# neurons

This is a simulation of a biological neural network based on numeric solutions to the Hodgkin-Huxley equations.

It is based on chapters 2-4 and appendix B from the book [Neuroscience - A Mathematical Primer by Alwyn Scott](https://www.springer.com/gp/book/9780387954035).

![Screencast](./screencast.gif)

## Installation

The easiest way to build the program is via [`dub`](https://dub.pm/). Either use `dub run neurons` to download and run the program or clone the repository and run `dub` inside.

## Notes

* The GUI itself is implemented using [GtkD](https://gtkd.org/). Because of this most of the code is somewhat object-oriented.

* The naming is purposefully verbose so that the code is as clear as possible.

* Here are some highlights from the code:
  * All the parameter metadata is specified using user-defined annotations in the [ParameterSet](./source/neurons/computation/parameter_set.d) struct.
  * The equations are solved numerically in the [simulateImpulse](./source/neurons/computation/impulse_simulation.d) function.
  * The [MutableSimulationWrapper](./source/neurons/computation/mutable_simulation_wrapper.d) creates a mutable container for the otherwise immutable [SimulationConfig](./source/neurons/computation/simulation_config.d) and [NeuralTreeSimulation](./source/neurons/computation/neural_tree_simulation.d) classes. The latter two are immutable because they are shared between threads. The former is mutable because once a new tree is generated we need to somehow update its reference in the GUI code (so we update its wrapper's reference).
  * A separate thread is launched using the [SimulationGenerator](./source/neurons/computation/simulation_generator.d) class for generating new neural trees without blocking the UI thread.
  * The tree painting happens in the [NeuralTreeCanvas](./source/neurons/gui/neural_tree_canvas.d) class.
