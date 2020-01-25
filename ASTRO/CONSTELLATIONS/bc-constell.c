#include "/home/user/BCGIT/ASTRO/bclib.h"

// TODO: special case for -pi/2? (maybe if dec <= -90 return OCTANS?)

int main(int argc, char **argv) {

  char name[100];

  furnsh_c("/home/user/BCGIT/ASTRO/standard.tm");

  for (double et = year2et(2020); et < year2et(2021); et += 86400) {

    strcpy(name, constellationName(obj2ConstellationNumber(301, et)));
    printf("%s MOON %s\n", stardate(et), name);
  }

  return 0;
}

