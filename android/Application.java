import co.ab180.airbridge.flutter.AirbridgeFlutter;
import io.flutter.app.FlutterApplication;

public class MainApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        AirbridgeFlutter.init(this, "nbreadab", "c79bec17356745faabccb845fe6f8039");
    }
}