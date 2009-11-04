#include "stdio.h"
#include "stdlib.h"
#include "math.h"

#define N 10000

// This code comes from
// http://ozviz.wasp.uwa.edu.au/~pbourke/fractals/lorenz/
// Use the build.sh script to generate the values.inc file
int main(int argc,char **argv)
{
   int i = 0;
   double x0, y0, z0, x1, y1, z1;
   double h = 0.01;
   double a = 10.0;
   double b = 28.0;
   double c = 8.0 / 3.0;

   x0 = 0.1;
   y0 = 0;
   z0 = 0;
   for (i = 0; i < N; i++) 
   {
      x1 = x0 + h * a * (y0 - x0);
      y1 = y0 + h * (x0 * (b - z0) - y0);
      z1 = z0 + h * (x0 * y0 - c * z0);
      x0 = x1;
      y0 = y1;
      z0 = z1;
      if (i > 100)
      {
         printf("%g, %g, %g,\n", x0, y0, z0);
      }
   }
}
