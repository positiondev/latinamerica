#include "random.h"
#include <stdlib.h>
#include <time.h> 
#include "urweb.h"

/* Note: This is not cryptographically secure (bad PRNG) - do not
   use in places where knowledge of the strings is a security issue.
*/

uw_Basis_unit uw_Random_init(uw_context ctx) {
  srand((unsigned int)time(0));
}

uw_Basis_string uw_Random_str(uw_context ctx, uw_Basis_int len) {
  uw_Basis_string s;
  int i;

  s = uw_malloc(ctx, len + 1);

  for (i = 0; i < len; i++) {
    s[i] = rand() % 93 + 33; /* ASCII characters 33 to 126 */
  }
  s[i] = 0;

  return s;
}

uw_Basis_string uw_Random_lower_str(uw_context ctx, uw_Basis_int len) {
  uw_Basis_string s;
  int i;

  s = uw_malloc(ctx, len + 1);

  for (i = 0; i < len; i++) {
    s[i] = rand() % 26 + 97; /* ASCII lowercase letters */
  }
  s[i] = 0;

  return s;
}
