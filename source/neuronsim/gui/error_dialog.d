module neuronsim.gui.error_dialog;

import adw.alert_dialog : AlertDialog;
import adw.types : ResponseAppearance;

class ErrorDialog : AlertDialog
{
    this(string messageText)
    {
        super();
        this.setTitle("An error occurred");
        this.setBody(messageText);
        this.addResponse("close", "OK");
        this.setResponseAppearance("close", ResponseAppearance.Suggested);
    }

    ulong connectClose(void delegate(ErrorDialog) callback)
    {
        return this.connectResponse("close", (string response) => callback(this));
    }
}
