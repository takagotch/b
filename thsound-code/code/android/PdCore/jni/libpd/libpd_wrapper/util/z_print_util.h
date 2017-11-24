/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
/*
 * Copyright (c) 2013 Dan Wilcox (danomatika@gmail.com) &
 *                    Peter Brinkmann (peter.brinkmann@gmail.com)
 *
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 */

#ifndef __Z_PRINT_UTIL_H__
#define __Z_PRINT_UTIL_H__

#include "z_libpd.h"

#ifdef __cplusplus
extern "C"
{
#endif

// Concatenate print messages into single lines before returning them to a print hook.
// ie "hello 123" is sent in 1 part -> "hello 123"
//
// For comparison, the default behavior returns individual words and spaces.
// ie "hello 123" is sent in 3 parts -> "hello", " ", "123"

// Assign the pointer to your print handler to this variable.
EXTERN t_libpd_printhook libpd_concatenated_printhook;

// Assign this function pointer to libpd_printhook or libpd_queued_printhook,
// depending on whether you're using queued messages, to intercept and
// concatenate print messages:
//
// libpd_printhook = (t_libpd_printhook) libpd_print_concatenator;
// libpd_concatenated_printhook = (t_libpd_printhook) yourPrintHandler;
//
// Note: The pointer argument is only good for the duration of the print 
//       callback; if you intend to use the argument after the callback has 
//       returned, you need to make a defensive copy.
//
void libpd_print_concatenator(const char *s);

#ifdef __cplusplus
}
#endif

#endif
