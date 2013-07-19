#include "hash.h"
#include <mhash.h>
#include <stdlib.h>
#include <time.h> 
#include "urweb.h"

uw_Basis_string uw_Hash_sha512(uw_context ctx, uw_Basis_string str) {
  uw_Basis_string hash;
  MHASH td;
  int i;
  unsigned char *buf;

  td = mhash_init(MHASH_SHA512);

  if (td == MHASH_FAILED) 
    uw_error(ctx, FATAL, "uw_Hash_sha512: mhash_init(MHASH_SHA512) failed.");
  
  buf = uw_malloc(ctx, mhash_get_block_size(MHASH_SHA512));
  hash = uw_malloc(ctx, (mhash_get_block_size(MHASH_SHA512) * 2) + 1);

  mhash(td, str, uw_Basis_strlen(ctx, str));
  buf = mhash_end(td);

  for(i = 0; i < mhash_get_block_size(MHASH_SHA512); i++) {
    sprintf((hash + 2*i), "%02x", buf[i]);
  }
  hash[2 * i] = '\0';

  return hash;
}


