module neurons.gui.neural_tree_window;

import gtk.MainWindow;
import gtk.Paned;
import gtk.ScrolledWindow;
import gtk.ProgressBar;

import neurons.gui.control_box;
import neurons.gui.neural_tree_canvas;

class NeuralTreeWindow : MainWindow
{
    enum PROGRESS_PULSE_STEP = 0.2;

    private
    {
        Paned outerPaned;
        Paned innerPaned;
        ScrolledWindow controlScrolledWindow;
        ScrolledWindow canvasScrolledWindow;
    }

    ControlBox controlBox;
    NeuralTreeCanvas canvas;
    ProgressBar progressBar;

    this()
    {
        super("neurons");

        outerPaned = new Paned(Orientation.VERTICAL);
        add(outerPaned);

        progressBar = new ProgressBar();
        progressBar.setPulseStep(PROGRESS_PULSE_STEP);
        outerPaned.pack1(progressBar, false, false);

        innerPaned = new Paned(Orientation.HORIZONTAL);
        outerPaned.pack2(innerPaned, true, false);

        controlScrolledWindow = new ScrolledWindow();
        controlScrolledWindow.setSizeRequest(500, -1);
        innerPaned.pack1(controlScrolledWindow, false, false);

        controlBox = new ControlBox();
        controlScrolledWindow.add(controlBox);

        canvasScrolledWindow = new ScrolledWindow();
        canvasScrolledWindow.setSizeRequest(NeuralTreeCanvas.MIN_SIZE, NeuralTreeCanvas.MIN_SIZE);
        innerPaned.pack2(canvasScrolledWindow, true, false);

        canvas = new NeuralTreeCanvas();
        canvasScrolledWindow.addWithViewport(canvas);
    }
}
