/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
package com.programmingsound.tasks.db;

import android.content.Context;
import android.database.sqlite.SQLiteDatabase;
import android.database.sqlite.SQLiteOpenHelper;

public class TasksDBHelper extends SQLiteOpenHelper {

  private static final String DB_NAME = "taskDB";
  private static final int VERSION = 1;

  public static final String TASK_TABLE               = "tasks";
  public static final String TASK_ID_COLUMN           = "_id"; // required by SimpleCursorAdapter
  public static final String TASK_TITLE_COLUMN        = "title";
  public static final String TASK_COMPLETE_COLUMN     = "compete";
  public static final String TASK_CREATED_AT_COLUMN   = "created_at";

  public TasksDBHelper(Context context) {
    super(context, DB_NAME, null, VERSION);
  }

  @Override
  public void onCreate(SQLiteDatabase db) {
    db.execSQL("CREATE TABLE " + TASK_TABLE + "(" +
        TASK_ID_COLUMN + " INTEGER PRIMARY KEY," +
        TASK_TITLE_COLUMN + " VARCHAR(255)," +
        TASK_COMPLETE_COLUMN + " INTEGER," +
        TASK_CREATED_AT_COLUMN + " VARCHAR DEFAULT CURRENT_TIMESTAMP" +
        ");");
  }

  @Override
  public void onUpgrade(SQLiteDatabase db, int oldVersion, int newVersion) {
    db.execSQL("DROP TABLE IF EXISTS " + TASK_TABLE + ";");
    onCreate(db);
  }

}
