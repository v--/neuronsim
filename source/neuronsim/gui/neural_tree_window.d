module neuronsim.gui.neural_tree_window;

import adw.application : Application;
import adw.application_window : ApplicationWindow;
import gtk.paned : Paned;
import gtk.progress_bar : ProgressBar;
import gtk.scrolled_window : ScrolledWindow;
import gtk.types : Orientation;

import neuronsim.gui.control_box;
import neuronsim.gui.neural_tree_canvas;

class NeuralTreeWindow : ApplicationWindow
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

    this(Application app)
    {
        super(app);

        this.outerPaned = new Paned(Orientation.Vertical);
        this.setContent(this.outerPaned);

        this.progressBar = new ProgressBar();
        this.progressBar.setPulseStep(PROGRESS_PULSE_STEP);
        this.outerPaned.startChild(this.progressBar);

        this.innerPaned = new Paned(Orientation.Horizontal);
        this.outerPaned.endChild(this.innerPaned);

        this.controlScrolledWindow = new ScrolledWindow();
        this.controlScrolledWindow.setSizeRequest(300, -1);
        this.innerPaned.startChild(this.controlScrolledWindow);

        this.controlBox = new ControlBox();
        this.controlScrolledWindow.setChild(this.controlBox);

        this.canvasScrolledWindow = new ScrolledWindow();
        this.canvasScrolledWindow.setSizeRequest(NeuralTreeCanvas.MIN_SIZE, NeuralTreeCanvas.MIN_SIZE);
        this.innerPaned.endChild(this.canvasScrolledWindow);

        this.canvas = new NeuralTreeCanvas();
        this.canvasScrolledWindow.setChild(this.canvas);
    }
}
