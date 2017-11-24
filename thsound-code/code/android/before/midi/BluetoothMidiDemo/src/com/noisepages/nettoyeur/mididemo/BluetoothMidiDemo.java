/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
/**
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL WARRANTIES, see the
 * file, "LICENSE.txt," in this distribution.
 * 
 * Piano GUI based on MyPiano by ZhangFL http://code.google.com/p/mobexamples/wiki/android_mypiano
 * http://www.eoeandroid.com/space.php?uid=1178
 */

package com.noisepages.nettoyeur.mididemo;

import java.io.IOException;

import android.app.Activity;
import android.bluetooth.BluetoothDevice;
import android.content.Intent;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.MotionEvent;
import android.view.View;
import android.widget.ImageButton;
import android.widget.Toast;

import com.noisepages.nettoyeur.bluetooth.BluetoothSppConnection;
import com.noisepages.nettoyeur.bluetooth.BluetoothSppObserver;
import com.noisepages.nettoyeur.bluetooth.midi.BluetoothMidiDevice;
import com.noisepages.nettoyeur.bluetooth.util.DeviceListActivity;
import com.noisepages.nettoyeur.midi.MidiReceiver;

/**
 * Bluetooth MIDI Demo app. The on-screen keyboard sends and receives MIDI note values between 60
 * and 72.
 * 
 * @author Peter Brinkmann (peter.brinkmann@gmail.com)
 */
public class BluetoothMidiDemo extends Activity implements View.OnTouchListener {

  private static final String TAG = "BluetoothMidiDemo";
  private static final int CONNECT = 1;
  private boolean touchState = false;
  private ImageButton[] keys;
  private final int[] imageUp = new int[] {R.drawable.white1, R.drawable.black1, R.drawable.white2,
      R.drawable.black2, R.drawable.white3, R.drawable.white4, R.drawable.black3,
      R.drawable.white5, R.drawable.black4, R.drawable.white6, R.drawable.black5,
      R.drawable.white7, R.drawable.white8};
  private final int[] imageDown = new int[] {R.drawable.white11, R.drawable.black11,
      R.drawable.white21, R.drawable.black21, R.drawable.white31, R.drawable.white41,
      R.drawable.black31, R.drawable.white51, R.drawable.black41, R.drawable.white61,
      R.drawable.black51, R.drawable.white71, R.drawable.white81};
  private BluetoothMidiDevice midiDevice = null;

  private final BluetoothSppObserver observer = new BluetoothSppObserver() {
    @Override
    public void onDeviceConnected(BluetoothDevice device) {
      toast("Device connected: " + device);
    }

    @Override
    public void onConnectionLost() {
      toast("MIDI connection lost");
    }

    @Override
    public void onConnectionFailed() {
      toast("MIDI connection failed");
    }
  };

  private final MidiReceiver receiver = new MidiReceiver.DummyReceiver() {
    @Override
    public void onNoteOn(int channel, int key, final int velocity) {
      final int index = key - 60;
      if (index >= 0 && index < 13) {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            if (velocity > 0)
              keyDown(index);
            else
              keyUp(index);
          }
        });
      }
    }

    @Override
    public void onNoteOff(int channel, int key, int velocity) {
      final int index = key - 60;
      if (index >= 0 && index < 13) {
        runOnUiThread(new Runnable() {
          @Override
          public void run() {
            keyUp(index);
          }
        });
      }
    }
  };

  private Toast toast = null;

  private void toast(final String msg) {
    runOnUiThread(new Runnable() {
      @Override
      public void run() {
        if (toast == null) {
          toast = Toast.makeText(getApplicationContext(), "", Toast.LENGTH_SHORT);
        }
        toast.setText(TAG + ": " + msg);
        toast.show();
      }
    });
  }

  @Override
  protected void onCreate(Bundle bundle) {
    super.onCreate(bundle);
    setContentView(R.layout.main);
    ImageButton white1 = (ImageButton) findViewById(R.id.white1);
    ImageButton white2 = (ImageButton) findViewById(R.id.white2);
    ImageButton white3 = (ImageButton) findViewById(R.id.white3);
    ImageButton white4 = (ImageButton) findViewById(R.id.white4);
    ImageButton white5 = (ImageButton) findViewById(R.id.white5);
    ImageButton white6 = (ImageButton) findViewById(R.id.white6);
    ImageButton white7 = (ImageButton) findViewById(R.id.white7);
    ImageButton white8 = (ImageButton) findViewById(R.id.white8);
    ImageButton black1 = (ImageButton) findViewById(R.id.black1);
    ImageButton black2 = (ImageButton) findViewById(R.id.black2);
    ImageButton black3 = (ImageButton) findViewById(R.id.black3);
    ImageButton black4 = (ImageButton) findViewById(R.id.black4);
    ImageButton black5 = (ImageButton) findViewById(R.id.black5);
    white1.setTag(0);
    white2.setTag(2);
    white3.setTag(4);
    white4.setTag(5);
    white5.setTag(7);
    white6.setTag(9);
    white7.setTag(11);
    white8.setTag(12);
    black1.setTag(1);
    black2.setTag(3);
    black3.setTag(6);
    black4.setTag(8);
    black5.setTag(10);
    keys =
        new ImageButton[] {white1, black1, white2, black2, white3, white4, black3, white5, black4,
            white6, black5, white7, white8};
    for (ImageButton key : keys) {
      key.setOnTouchListener(this);
    }
    try {
      midiDevice = new BluetoothMidiDevice(observer, receiver);
    } catch (IOException e) {
      toast("Bluetooth MIDI not available");
      e.printStackTrace();
    }
  }

  @Override
  protected void onDestroy() {
    super.onDestroy();
    cleanup();
  }

  private void cleanup() {
    if (midiDevice != null) {
      midiDevice.close();
      midiDevice = null;
    }
  }

  public boolean onTouch(View view, MotionEvent motionEvent) {
    if (!(view instanceof ImageButton)) return false;
    ImageButton key = (ImageButton) view;
    Object tag = key.getTag();
    if (tag == null || !(tag instanceof Integer)) return false;
    int index = (Integer) tag;
    int action = motionEvent.getAction();
    if (action == MotionEvent.ACTION_DOWN && !touchState) {
      touchState = true;
      midiDevice.getMidiOut().onNoteOn(0, index + 60, 100);
      keyDown(index);
    } else if (action == MotionEvent.ACTION_UP && touchState) {
      touchState = false;
      midiDevice.getMidiOut().onNoteOff(0, index + 60, 64);
      keyUp(index);
    }
    return true;
  }

  private void keyDown(int n) {
    keys[n].setImageResource(imageDown[n]);
  }

  private void keyUp(int n) {
    keys[n].setImageResource(imageUp[n]);
  }

  @Override
  public boolean onCreateOptionsMenu(Menu menu) {
    MenuInflater inflater = getMenuInflater();
    inflater.inflate(R.menu.menu, menu);
    return true;
  }

  @Override
  public boolean onOptionsItemSelected(MenuItem item) {
    switch (item.getItemId()) {
      case R.id.connect_item:
        if (midiDevice.getConnectionState() == BluetoothSppConnection.State.NONE) {
          startActivityForResult(new Intent(this, DeviceListActivity.class), CONNECT);
        } else {
          midiDevice.close();
        }
        return true;
      default:
        return super.onOptionsItemSelected(item);
    }
  }

  @Override
  public void onActivityResult(int requestCode, int resultCode, Intent data) {
    switch (requestCode) {
      case CONNECT:
        if (resultCode == Activity.RESULT_OK) {
          String address = data.getExtras().getString(DeviceListActivity.DEVICE_ADDRESS);
          try {
            midiDevice.connect(address);
          } catch (IOException e) {
            toast(e.getMessage());
          }
        }
        break;
    }
  }
}
