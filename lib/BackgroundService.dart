import 'dart:async';
import 'dart:ui';
import 'package:flutter_background_service/flutter_background_service.dart';

Future<void> initializeService() async
{
  final service=FlutterBackgroundService();
  await service.configure(androidConfiguration: AndroidConfiguration(onStart: onStart,isForegroundMode: true,autoStart: true), iosConfiguration: IosConfiguration());
}
@pragma('vm:entry-point')
void onStart(ServiceInstance service)  async {
  DartPluginRegistrant.ensureInitialized();
  if(service is AndroidServiceInstance)
  {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
     });
    print('foreground service running');
  }
  service.on('stopService').listen((event){
    service.stopSelf();
  });
  Timer.periodic(const Duration(minutes: 15), (timer) async{
    if(service is AndroidServiceInstance)
    {
      if(await service.isForegroundService())
      {
        service.setForegroundNotificationInfo(title: 'BlinGlyph', content: 'Ready to Glyph. Turn off this notification in your phone settings.');
      }
    }
    
    service.invoke('update');
  });

}