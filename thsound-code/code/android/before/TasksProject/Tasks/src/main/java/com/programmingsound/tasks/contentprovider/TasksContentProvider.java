/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
package com.programmingsound.tasks.contentprovider;

import android.content.ContentProvider;
import android.content.ContentResolver;
import android.content.ContentValues;
import android.content.UriMatcher;
import android.database.Cursor;
import android.database.sqlite.SQLiteDatabase;
import android.net.Uri;

import com.programmingsound.tasks.db.TasksDBHelper;

import static com.programmingsound.tasks.db.TasksDBHelper.*;

public class TasksContentProvider extends ContentProvider {

  private TasksDBHelper dbHelper;
  private UriMatcher uriMatcher;

  private static final String AUTHORITY = "com.programmingsound.tasks.contentprovider";
  private static final String BASE_PATH = "tasks";
  private static final int MATCH_TASKS_PATH = 1;
  private static final int MATCH_TASK_PATH = 10;
  public static final Uri CONTENT_URI = Uri.parse("content://" + AUTHORITY + "/" + BASE_PATH);
  public static final String CONTENT_TYPE = ContentResolver.CURSOR_DIR_BASE_TYPE + "/tasks";
  public static final String CONTENT_ITEM_TYPE = ContentResolver.CURSOR_ITEM_BASE_TYPE + "/task";
  public static final String[] TASKS_PROJECTION = {
      TASK_ID_COLUMN,
      TASK_TITLE_COLUMN,
      TASK_COMPLETE_COLUMN,
      TASK_CREATED_AT_COLUMN
  };
  public static final int PROJECTION_POSITION_ID = 0;
  public static final int PROJECTION_POSITION_TITLE = 1;
  public static final int PROJECTION_POSITION_COMPLETE = 2;
  public static final int PROJECTION_POSITION_CREATED_AT = 3;

  @Override public boolean onCreate() {
    dbHelper = new TasksDBHelper(getContext());
    uriMatcher = new UriMatcher(UriMatcher.NO_MATCH);
    uriMatcher.addURI(AUTHORITY, BASE_PATH, MATCH_TASKS_PATH);
    uriMatcher.addURI(AUTHORITY, BASE_PATH + "/#", MATCH_TASK_PATH);
    return true;
  }

  @Override public Cursor query(Uri uri, String[] projection, String selection, String[] selectionArgs, String sortOrder) {
    SQLiteDatabase db = dbHelper.getReadableDatabase();
    Cursor cursor = null;
    if (uriMatcher.match(uri) == MATCH_TASKS_PATH) {
      cursor = db.query(TASK_TABLE, projection, selection, selectionArgs, null, null, sortOrder);
      cursor.setNotificationUri(getContext().getContentResolver(), uri);
    } else {
      throw new IllegalArgumentException("Invalid URI for Tasks query");
    }
    return cursor;
  }

  @Override public Uri insert(Uri uri, ContentValues values) {
    if (uriMatcher.match(uri) == MATCH_TASKS_PATH) {
      SQLiteDatabase db = dbHelper.getWritableDatabase();
      long newId = db.insert(TASK_TABLE, null, values);
      getContext().getContentResolver().notifyChange(uri, null);
      return Uri.parse(BASE_PATH + "/" + newId);
    } else {
      throw new IllegalArgumentException("Invalid URI for Task insert");
    }
  }

  @Override public int delete(Uri uri, String selection, String[] selectionArgs) {
    SQLiteDatabase db = dbHelper.getWritableDatabase();
    int match = uriMatcher.match(uri);
    int rowsDeleted = 0;
    if (match == MATCH_TASK_PATH) {
      // ignore selection and args, delete from id
      String id = uri.getLastPathSegment();
      rowsDeleted = db.delete(TASK_TABLE, TASK_ID_COLUMN + "=" + id, null);
    } else if (match == MATCH_TASKS_PATH) {
      rowsDeleted = db.delete(TASK_TABLE, selection, selectionArgs);
    } else {
      throw new IllegalArgumentException("Invalid URI for Task delete");
    }
    getContext().getContentResolver().notifyChange(uri, null);
    return rowsDeleted;
  }

  @Override public int update(Uri uri, ContentValues values, String selection, String[] selectionArgs) {
    SQLiteDatabase db = dbHelper.getWritableDatabase();
    int match = uriMatcher.match(uri);
    int rowsUpdated = 0;
    if (match == MATCH_TASK_PATH) {
      // ignore selection and args, update from id
      String id = uri.getLastPathSegment();
      rowsUpdated = db.update(TASK_TABLE, values, TASK_ID_COLUMN + "=" + id, null);
    } else if (match == MATCH_TASKS_PATH) {
      rowsUpdated = db.update(TASK_TABLE, values, selection, selectionArgs);
    } else {
      throw new IllegalArgumentException("Invalid URI for Task delete");
    }
    getContext().getContentResolver().notifyChange(uri, null);
    return rowsUpdated;
  }

  @Override public String getType(Uri uri) {
    return null;
  }

}
