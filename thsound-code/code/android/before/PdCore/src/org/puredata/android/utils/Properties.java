/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
/**
 * 
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 * 
 */

package org.puredata.android.utils;

import android.os.Build;

/**
 *
 * Properties is a utility class that checks whether armeabi-v7a is available.
 * 
 * @author Peter Brinkmann (peter.brinkmann@gmail.com)
 *
 */
public class Properties {

	/**
	 * Android version as an integer (e.g., 8 for FroYo)
	 */
	@SuppressWarnings("deprecation")
	public static final int version = Integer.parseInt(Build.VERSION.SDK);
	
}
