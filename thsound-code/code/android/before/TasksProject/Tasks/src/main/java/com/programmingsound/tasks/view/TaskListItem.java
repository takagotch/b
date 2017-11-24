/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
package com.programmingsound.tasks.view;

import android.content.ContentValues;
import android.content.Context;
import android.net.Uri;
import android.util.AttributeSet;
import android.view.KeyEvent;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.CheckBox;
import android.widget.CompoundButton;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.programmingsound.tasks.R;
import com.programmingsound.tasks.audio.PdInterface;
import com.programmingsound.tasks.db.TasksDBHelper;

public class TaskListItem extends RelativeLayout {

  private EditText taskTitle;
  private Uri taskUri;
  private CheckBox completeCheckbox;

  public TaskListItem(Context context, AttributeSet attrs) {
    super(context, attrs);
  }

  public void setTaskUri(Uri uri) {
    taskUri = uri;
  }

  @Override protected void onFinishInflate() {
    super.onFinishInflate();
    taskTitle = (EditText) findViewById(R.id.task_title_text);
    taskTitle.setOnEditorActionListener(editorActionListener);
    completeCheckbox = (CheckBox) findViewById(R.id.task_complete_check box);
    completeCheckbox.setOnCheckedChangeListener(checkedChangedListener);
  }

  private void updateTask() {
    ContentValues values = new ContentValues(2);
    values.put(TasksDBHelper.TASK_TITLE_COLUMN, taskTitle.getText().toString());
    values.put(TasksDBHelper.TASK_COMPLETE_COLUMN, completeCheckbox.isChecked());
    getContext().getContentResolver().update(taskUri, values, null, null);
  }

  private TextView.OnEditorActionListener editorActionListener = new TextView.OnEditorActionListener() {
    @Override public boolean onEditorAction(TextView v, int actionId, KeyEvent event) {
      boolean handled = false;
      if (actionId == EditorInfo.IME_ACTION_DONE) {
        updateTask();
        handled = true;
        // Incantation to dismiss the keyboard
        InputMethodManager imm = (InputMethodManager) getContext().getSystemService(Context.INPUT_METHOD_SERVICE);
        imm.hideSoftInputFromWindow(taskTitle.getWindowToken(), 0);
      }
      return handled;
    }
  };

  private CompoundButton.OnCheckedChangeListener checkedChangedListener = new CompoundButton.OnCheckedChangeListener() {
    @Override public void onCheckedChanged(CompoundButton buttonView,
                                           boolean isChecked) {
      updateTask();
    }
  };

}
