package app.capgo.plugin.health;

import com.getcapacitor.Logger;

public class Health {

    public String echo(String value) {
        Logger.info("Echo", value);
        return value;
    }
}
