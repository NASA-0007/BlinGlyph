import 'dart:async';
import 'package:nothing_glyph_interface/nothing_glyph_interface.dart';
import 'glyph_map.dart';
import 'phone.dart';

class GlyphTrigger {
  static bool stopExecution = false;
  static int i = 0;
  static bool rev = false;
  Timer? glyphTimer;
  final NothingGlyphInterface glyphInterface;
  GlyphTrigger(this.glyphInterface);

  void buildChannelC(Phone phone, GlyphFrameBuilder builder) {
    switch (phone) {
      case Phone.phone1:
        builder.buildChannel(Phone1GlyphMap.c1.idx);
        builder.buildChannel(Phone1GlyphMap.c2.idx);
        builder.buildChannel(Phone1GlyphMap.c3.idx);
        builder.buildChannel(Phone1GlyphMap.c4.idx);
        break;
      case Phone.phone2:
        builder.buildChannel(Phone2GlyphMap.c1_1.idx);
        builder.buildChannel(Phone2GlyphMap.c1_2.idx);
        builder.buildChannel(Phone2GlyphMap.c1_3.idx);
        builder.buildChannel(Phone2GlyphMap.c1_4.idx);
        builder.buildChannel(Phone2GlyphMap.c1_5.idx);
        builder.buildChannel(Phone2GlyphMap.c1_6.idx);
        builder.buildChannel(Phone2GlyphMap.c1_7.idx);
        builder.buildChannel(Phone2GlyphMap.c1_8.idx);
        builder.buildChannel(Phone2GlyphMap.c1_9.idx);
        builder.buildChannel(Phone2GlyphMap.c1_10.idx);
        builder.buildChannel(Phone2GlyphMap.c1_11.idx);
        builder.buildChannel(Phone2GlyphMap.c1_12.idx);
        builder.buildChannel(Phone2GlyphMap.c1_13.idx);
        builder.buildChannel(Phone2GlyphMap.c1_14.idx);
        builder.buildChannel(Phone2GlyphMap.c1_15.idx);
        builder.buildChannel(Phone2GlyphMap.c1_16.idx);
        break;
      case Phone.phone2a:
        builder.buildChannelC();
        break;
      default:
        throw UnimplementedError();
    }
  }

  Future<void> initialGlyph(GlyphMap glyph, Phone phone) async {
    var builder = GlyphFrameBuilder();

    // Choose glyph channel
    if (glyph.group != null) {
      switch (glyph.group) {
        case "d1":
          builder.buildChannelD();
          break;
        case "c1":
        case "c":
          buildChannelC(phone, builder);
          break;
      }
    } else {
      builder.buildChannel(glyph.idx);
    }

    // Set common properties
    builder.buildPeriod(2000); // 2 seconds period
    builder.buildCycles(1);

    await glyphInterface.buildGlyphFrame(builder.build());
    await glyphInterface.animate();

    // Start a 2-second timer to update glyph progress
    _startGlyphTimer(2000);
    await glyphInterface.turnOff();
  }

  void _startGlyphTimer(int durationMs) {
    const int updateInterval =22; // Roughly 60 FPS, update every 17ms
    int elapsed = 0;
    int progress=0;
    // Cancel any existing timer before starting a new one
    _cancelGlyphTimer();

    // Timer runs at 17ms intervals until the total duration (2000ms) is reached
    glyphTimer = Timer.periodic(const Duration(milliseconds: updateInterval), (timer) async {
      if (stopExecution) {
        timer.cancel();
        stopExecution = false; // Reset the stop flag for future runs
        _startCountdownTimer(progress);
        print("Timer stopped externally.");
        return;
      }

      elapsed += updateInterval;

      // Calculate progress as a percentage of 0 to 100 based on elapsed time
      progress = (elapsed / durationMs * 100).clamp(0, 100).toInt();
      print("Elapsed: $elapsed ms, Progress: $progress%");
      await glyphInterface.displayProgress(progress); // Display progress on glyph
      if (elapsed >= durationMs) {
        glyphInterface.turnOff();
        timer.cancel();
        print("2 seconds reached. Glyph animation completed.");
        // Turn off glyph after completion
      }
    });
  }
void _startCountdownTimer(int startProgress) {
    const int updateInterval = 22; // Roughly 60 FPS, update every 17ms
    int progress = startProgress;

    glyphTimer = Timer.periodic(const Duration(milliseconds: updateInterval), (timer) async {

      progress -= (100 / (350 / updateInterval)).toInt(); // Calculate the step decrement
      progress = progress.clamp(0, 100); // Ensure progress stays between 0 and 100
      print("Countdown Progress: $progress%");

      await glyphInterface.displayProgress(progress);
      if (progress == 0) {
        timer.cancel();
        print("Glyph animation completed.");
        glyphInterface.turnOff(); // Update glyph with countdown progress
      }
    }
    );
    return;
  }
  // Function to stop the glyph animation and cancel the timer
  void stopGlyph() {
    stopExecution = true;
    _cancelGlyphTimer();
  }

Future<void> multiGlyphE(Phone phone) async {
    GlyphFrameBuilder builder;
    // ignore: non_constant_identifier_names
    GlyphFrameBuilder Ebuilder= GlyphFrameBuilder();
    // Choose glyph channel
    builder=Ebuilder.buildChannelE();
    // Set common properties
    builder.buildPeriod(70);
    builder.buildCycles(1);

    await glyphInterface.buildGlyphFrame(builder.build());
    await glyphInterface.animate();
    await Future.delayed(const Duration(milliseconds: 60));
    await multiGlyphD(phone);
  }

Future<void> multiGlyphD(Phone phone) async {
    GlyphFrameBuilder builder;
    // ignore: non_constant_identifier_names
    GlyphFrameBuilder Dbuilder= GlyphFrameBuilder();
    // Choose glyph channel
    builder=Dbuilder.buildChannelD();
    // Set common properties
    builder.buildPeriod(70);
    builder.buildCycles(1);

    await glyphInterface.buildGlyphFrame(builder.build());
    await glyphInterface.animate();
    await Future.delayed(const Duration(milliseconds: 60));
    await multiGlyphC(phone);
  }

  Future<void> multiGlyphC(Phone phone) async {
    GlyphFrameBuilder builder;
    // ignore: non_constant_identifier_names
    GlyphFrameBuilder Cbuilder= GlyphFrameBuilder();
    // Choose glyph channel
    builder=Cbuilder.buildChannelC();
    // Set common properties
    builder.buildPeriod(70);
    builder.buildCycles(1);

    await glyphInterface.buildGlyphFrame(builder.build());
    await glyphInterface.animate();
    await Future.delayed(const Duration(milliseconds: 60));
    if (phone.formattedName!="Phone (2a)")
    {
    await multiGlyphB(phone);
    }
    else
    {
      await glyphInterface.turnOff();
    }
  }

  Future<void> multiGlyphB(Phone phone) async {
    GlyphFrameBuilder builder;
    // ignore: non_constant_identifier_names
    GlyphFrameBuilder Bbuilder= GlyphFrameBuilder();
    // Choose glyph channel
    builder=Bbuilder.buildChannelB();
    // Set common properties
    builder.buildPeriod(100);
    builder.buildCycles(1);

    await glyphInterface.buildGlyphFrame(builder.build());
    await glyphInterface.animate();
    await Future.delayed(const Duration(milliseconds: 80));
    if (phone.formattedName!="Phone (2a)")
    {
    await multiGlyphA(phone);
    }
  }

  Future<void> multiGlyphA(Phone phone) async {
    GlyphFrameBuilder builder;
    // ignore: non_constant_identifier_names
    GlyphFrameBuilder Abuilder= GlyphFrameBuilder();
    // Choose glyph channel
    builder=Abuilder.buildChannelA();
    // Set common properties
    builder.buildPeriod(90);  
    builder.buildCycles(1);

    await glyphInterface.buildGlyphFrame(builder.build());
    await glyphInterface.animate();
    await Future.delayed(const Duration(milliseconds: 60));
    await glyphInterface.turnOff();
  }


  // Helper function to cancel the timer
  void _cancelGlyphTimer() {  
    if (glyphTimer != null && glyphTimer!.isActive) {
      glyphTimer!.cancel();
      print("Glyph timer canceled.");
    }
  }
}
