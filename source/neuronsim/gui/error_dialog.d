module neuronsim.gui.error_dialog;

import gtk.Window;
import gtk.MessageDialog;

class ErrorDialog : MessageDialog
{
    this(Window parentWindow, string messageText)
    {
        super(parentWindow, GtkDialogFlags.MODAL, MessageType.INFO, ButtonsType.OK, messageText);
        setTitle("An error occurred");
    }

    void addOnOKResponse(void delegate(ErrorDialog) dlg)
    {
        addOnResponse((response, dialog) {
            if (response == ResponseType.OK)
                dlg(this);
        });
    }
}
