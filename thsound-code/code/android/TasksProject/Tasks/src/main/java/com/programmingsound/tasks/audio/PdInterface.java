/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
package com.programmingsound.tasks.audio;

import java.io.File;
import java.io.IOException;
import java.io.InputStream;

import org.puredata.android.io.AudioParameters;
import org.puredata.android.io.PdAudio;
import org.puredata.core.PdBase;
import org.puredata.core.utils.IoUtils;

import com.programmingsound.tasks.R;

import android.content.Context;
import android.os.Handler;

public class PdInterface {
  private static final int MIN_SAMPLE_RATE        = 44100;
  private static final String MODULATOR_1_TUNE 	  = "mod1_tune";
  private static final String MODULATOR_2_TUNE 	  = "mod2_tune";
  private static final String MODULATOR_1_DEPTH 	= "mod1_depth";
  private static final String MODULATOR_2_DEPTH 	= "mod2_depth";
  private static final String MIDINOTE1 			    = "midinote1";
  private static final String MIDINOTE2 			    = "midinote2";
  private static final long NOTE_DELAY 			      = 120;
  private static final int[] scaleDegrees         = {
    0, 2, 4, 5, 7, 9, 11, 12, 14, 16 
  };
  private static final int ROOT_MIDI_NOTE         = 60;

  private static PdInterface ourInstance = new PdInterface();
  private Context context;
  private Handler handler;
  private int currentRootNote;
  private int currentSecondNote;
  private int currentDegree;
  private int currentOctave;

  public static PdInterface getInstance() {
    return ourInstance;
  }

  private PdInterface() { }

  public void initialize(Context context) {
    this.context = context;
    this.handler = new Handler();
    try {
      initializePd();
      resetScaleDegree();
    } catch (IOException e) {
      // Unable to initialize audio. Ignore silently as this is not fatal to the app
      e.printStackTrace();
    }
  }

  public void destroy() {
    cleanup();
  }

  public void playNewTaskCue() {
    PdBase.sendFloat(MIDINOTE1, ROOT_MIDI_NOTE);
    resetScaleDegree();
  }

  public void playCompleteTaskCue() {
    final float third = currentSecondNote;
    PdBase.sendFloat(MIDINOTE1, currentRootNote);
    handler.postDelayed(new Runnable() {
      @Override public void run() {
        PdBase.sendFloat(MIDINOTE2, third);
      }
    }, NOTE_DELAY);
    incrementScaleDegree();
  }

  public void playClearTasksCue() {
    final int root = ROOT_MIDI_NOTE;
    final int third = ROOT_MIDI_NOTE + scaleDegrees[2];
    PdBase.sendFloat(MIDINOTE1, root);
    PdBase.sendFloat(MIDINOTE2, third);
    handler.postDelayed(new Runnable() {
      @Override public void run() {
        PdBase.sendFloat(MIDINOTE1, root + 12);
        PdBase.sendFloat(MIDINOTE2, third + 12);
      }
    }, NOTE_DELAY);
    resetScaleDegree();
  }
  
  protected void resetScaleDegree() {
    currentRootNote = ROOT_MIDI_NOTE;
    int secondDegree = scaleDegrees[2];
    currentSecondNote = ROOT_MIDI_NOTE + secondDegree;
    currentDegree = 0;
    currentOctave = 0;
  }
  
  protected void incrementScaleDegree() {
    currentDegree++;
    if (currentDegree == 7) {
      currentDegree = 0;
      currentOctave++;
    }
    int rootDegree = scaleDegrees[currentDegree];
    int nextDegree = scaleDegrees[currentDegree + 2];
    currentRootNote = ROOT_MIDI_NOTE + (12 * currentOctave) + rootDegree;
    currentSecondNote = ROOT_MIDI_NOTE + (12 * currentOctave) + nextDegree;
  }

  private void initializePd() throws IOException {
    AudioParameters.init(context);
    int sampleRate = Math.max(MIN_SAMPLE_RATE, AudioParameters.suggestSampleRate());
    int outChannels = AudioParameters.suggestOutputChannels();
    PdAudio.initAudio(sampleRate, 0, outChannels, 1, true);
    File dir = context.getFilesDir();
    File patchFile = new File(dir, "task_tones.pd");
    InputStream patchStream = context.getResources().openRawResource(R.raw.patches);
    IoUtils.extractZipResource(patchStream, dir, true);

    PdBase.openPatch(patchFile.getAbsolutePath());
    PdBase.sendFloat(MODULATOR_1_TUNE, 0);
    PdBase.sendFloat(MODULATOR_1_DEPTH, 0);
    PdBase.sendFloat(MODULATOR_2_TUNE, 0.5f);
    PdBase.sendFloat(MODULATOR_2_DEPTH, 10000);
  }

  private void cleanup() {
    PdAudio.release();
    PdBase.release();
  }

}
