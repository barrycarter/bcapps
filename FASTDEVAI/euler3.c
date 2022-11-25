# ANSWER BELOW IS WRONG, YIELDS 1471 NOT 6857

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main(int argc, char *argv[])
{
	long long int num = 600851475143;
	long long int i = 2;
	long long int max = 0;
	while (i < num)
	{
		if (num % i == 0)
		{
			num = num / i;
			max = i;
		}
		i++;
	}
	printf("%lld\n", max);
	return 0;
}
