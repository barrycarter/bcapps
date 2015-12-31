// testing varargs

#include <stdio.h>
#include <stdarg.h>

double average(int num,...) {

  va_list valist;
  va_start(valist, num);

  char *str = va_arg(valist,char *);
  int n = va_arg(valist,int);
  double f = va_arg(valist,double);

  double yikes = va_arg(valist,double);

  printf("GOT: %s %d %f %f\n",str,n,f,yikes);


  /* clean memory reserved for valist */
  va_end(valist);

  return 0.0;

}

int main() {
  average(3,"hello",7,2.2);
}

