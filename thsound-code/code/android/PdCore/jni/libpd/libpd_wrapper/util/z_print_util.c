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

#include "z_print_util.h"

#include <stdlib.h>
#include <string.h>

t_libpd_printhook libpd_concatenated_printhook = NULL;

#define PRINT_LINE_SIZE 2048

void libpd_print_concatenator(const char *s) {
  if (!libpd_concatenated_printhook) return;

  static char concatenated_print_line[PRINT_LINE_SIZE];
  static int len_line = 0;
  concatenated_print_line[len_line] = '\0';

  int len = strlen(s);
  while (len_line + len >= PRINT_LINE_SIZE) {
    int d = PRINT_LINE_SIZE - 1 - len_line;
    strncat(concatenated_print_line, s, d);
    libpd_concatenated_printhook(concatenated_print_line);
    s += d;
    len -= d;
    len_line = 0;
    concatenated_print_line[0] = '\0';
  }

  strncat(concatenated_print_line, s, len);
  len_line += len;

  if (len_line > 0 && concatenated_print_line[len_line - 1] == '\n') {
    concatenated_print_line[len_line - 1] = '\0';
    libpd_concatenated_printhook(concatenated_print_line);
    len_line = 0;
  }
}
