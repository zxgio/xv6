#include "types.h"
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
  char *buf = (char *)(argc-1);
  buf[0] = 'a';
  exit();
}
