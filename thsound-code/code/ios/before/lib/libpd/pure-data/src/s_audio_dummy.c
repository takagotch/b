/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
/*
 * Copyright (c) 2010 Peter Brinkmann (peter.brinkmann@gmail.com)
 *
 * For information on usage and redistribution, and for a DISCLAIMER OF ALL
 * WARRANTIES, see the file, "LICENSE.txt," in this distribution.
 */

#ifdef USEAPI_DUMMY

#include <stdio.h>

int dummy_open_audio(int nin, int nout, int sr) {
  return 0;
}

int dummy_close_audio() {
  return 0;
}

int dummy_send_dacs() {
  return 0;
}

void dummy_getdevs(char *indevlist, int *nindevs, char *outdevlist,
    int *noutdevs, int *canmulti, int maxndev, int devdescsize) {
  sprintf(indevlist, "NONE");
  sprintf(outdevlist, "NONE");
  *nindevs = *noutdevs = 1;
  *canmulti = 0;
}

void dummy_listdevs() {
  // do nothing
}

#endif

