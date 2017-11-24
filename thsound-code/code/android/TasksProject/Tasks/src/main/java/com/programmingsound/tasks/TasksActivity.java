/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
package com.programmingsound.tasks;

import org.puredata.android.io.PdAudio;

import android.app.Activity;
import android.app.LoaderManager;
import android.content.ContentValues;
import android.content.Context;
import android.content.CursorLoader;
import android.content.Loader;
import android.database.Cursor;
import android.net.Uri;
import android.os.Bundle;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.CursorAdapter;
import android.widget.ListView;
import android.widget.TextView;

import com.programmingsound.tasks.audio.PdInterface;
import com.programmingsound.tasks.contentprovider.TasksContentProvider;
import com.programmingsound.tasks.db.TasksDBHelper;
import com.programmingsound.tasks.view.TaskListItem;

public class TasksActivity extends Activity implements LoaderManager.LoaderCallbacks<Cursor> {

  private ListView listView;
  private TasksCursorAdapter adapter;

  /*
    Lifecycle
   */

  @Override protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_tasks);
    listView = (ListView)findViewById(R.id.task_list);
    PdInterface.getInstance().initialize(this);
    loadTasks();
  }

  @Override protected void onStart() {
    super.onStart();
    PdAudio.startAudio(this);
  }

  @Override protected void onStop() {
    PdAudio.stopAudio();
    super.onStop();
  }

  @Override protected void onDestroy() {
    PdInterface.getInstance().destroy();
    super.onDestroy();
  }

  /*
    Task Logic
   */

  private void loadTasks() {
    getLoaderManager().initLoader(1, null, this);
    adapter = new TasksCursorAdapter(this, null, CursorAdapter.FLAG_REGISTER_CONTENT_OBSERVER);
    listView.setAdapter(adapter);
  }

  private void createNewTask() {
    Uri tasksUri = TasksContentProvider.CONTENT_URI;
    ContentValues values = new ContentValues(2);
    values.put(TasksDBHelper.TASK_TITLE_COLUMN, "New Task");
    values.put(TasksDBHelper.TASK_COMPLETE_COLUMN, 0);
    getContentResolver().insert(tasksUri, values);
    PdInterface.getInstance().playNewTaskCue();
  }

  private void clearComplete() {
    Uri tasksUri = TasksContentProvider.CONTENT_URI;
    getContentResolver().delete(
        tasksUri,
        TasksDBHelper.TASK_COMPLETE_COLUMN + "=1",
        null);
    PdInterface.getInstance().playClearTasksCue();
  }

  /*
    Adapter
   */

  private class TasksCursorAdapter extends CursorAdapter {

    public TasksCursorAdapter(Context context, Cursor c, int flags) {
      super(context, c, flags);
    }

    @Override public View newView(Context context, Cursor cursor, ViewGroup parent) {
      return View.inflate(context, R.layout.item_task, null);
    }

    @Override public void bindView(View view, Context context, Cursor cursor) {
      TaskListItem listItem = (TaskListItem)view;
      int id = cursor.getInt(TasksContentProvider.PROJECTION_POSITION_ID);
      Uri taskUri = Uri.parse(TasksContentProvider.CONTENT_URI + "/" + id);
      listItem.setTaskUri(taskUri);
      String title = cursor.getString(TasksContentProvider.PROJECTION_POSITION_TITLE);
      boolean isComplete = cursor.getInt(TasksContentProvider.PROJECTION_POSITION_COMPLETE) == 1;
      TextView titleTextView = (TextView)view.findViewById(R.id.task_title_text);
      CheckBox completeCheckbox = (CheckBox)view.findViewById(R.id.task_complete_checkbox);
      titleTextView.setText(title);
      completeCheckbox.setChecked(isComplete);
    }
  };

  /*
    Menu
   */

  @Override public boolean onCreateOptionsMenu(Menu menu) {
    MenuInflater inflater = getMenuInflater();
    inflater.inflate(R.menu.tasks, menu);
    return true;
  }

  @Override public boolean onOptionsItemSelected(MenuItem item) {
    int id = item.getItemId();
    if (id == R.id.menu_item_new_task) {
      createNewTask();
      return true;
    } else if (id == R.id.menu_item_clear_complete) {
      clearComplete();
      return true;
    }
    return super.onOptionsItemSelected(item);
  }

  /*
    Loader Callbacks
   */

  @Override public Loader<Cursor> onCreateLoader(int loaderId, Bundle bundle) {
    CursorLoader loader = new CursorLoader(
        this,
        TasksContentProvider.CONTENT_URI,
        TasksContentProvider.TASKS_PROJECTION,
        null, null, null
        );
    return loader;
  }

  @Override public void onLoadFinished(Loader<Cursor> cursorLoader, Cursor cursor) {
    adapter.swapCursor(cursor);
  }

  @Override public void onLoaderReset(Loader<Cursor> cursorLoader) {
    adapter.swapCursor(null);
  }
}
