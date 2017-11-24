/***
 * Excerpted from "Programming Sound with Pure Data",
 * published by The Pragmatic Bookshelf.
 * Copyrights apply to this code. It may not be used to create training material, 
 * courses, books, articles, and the like. Contact us if you are in doubt.
 * We make no guarantees that this code is fit for any purpose. 
 * Visit http://www.pragmaticprogrammer.com/titles/thsound for more book information.
***/
#include <stdio.h>
#include "z_libpd.h"

void pdprint(const char *s) {
  printf("%s", s);
}

void pdnoteon(int ch, int pitch, int vel) {
  printf("noteon: %d %d %d\n", ch, pitch, vel);
}

int main(int argc, char **argv) {
  if (argc < 3) {
    fprintf(stderr, "usage: %s file folder\n", argv[0]);
    return -1;
  }

  // init pd
  int srate = 44100;
  libpd_printhook = (t_libpd_printhook) pdprint;
  libpd_noteonhook = (t_libpd_noteonhook) pdnoteon;
  libpd_init();
  libpd_init_audio(1, 2, srate);
  float inbuf[64], outbuf[128];  // one input channel, two output channels
                                 // block size 64, one tick per buffer

  // compute audio    [; pd dsp 1(
  libpd_start_message(1); // one entry in list
  libpd_add_float(1.0f);
  libpd_finish_message("pd", "dsp");

  // open patch       [; pd open file folder(
  libpd_openfile(argv[1], argv[2]);

  // now run pd for ten seconds (logical time)
  int i;
  for (i = 0; i < 10 * srate / 64; i++) {
    // fill inbuf here
    libpd_process_float(1, inbuf, outbuf);
    // use outbuf here
  }

  return 0;
}

