import co.ab180.airbridge.flutter.AirbridgeFlutter;
import io.flutter.app.FlutterApplication;

public class MainApplication extends FlutterApplication {
    @Override
    public void onCreate() {
        super.onCreate();
        AirbridgeFlutter.init(this, "YOUR_APP_NAME", "YOUR_APP_TOKEN");
    }
}