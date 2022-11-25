#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int is_abundant(int n)
{
	int i, sum = 0;
	for (i = 1; i <= sqrt(n); i++)
	{
		if (n % i == 0)
		{
			sum += i;
			if (i != 1 && i != sqrt(n))
				sum += n / i;
		}
	}
	return sum > n;
}

int main()
{
	int i, j, sum = 0;
	int *abundant = (int *)malloc(sizeof(int) * 28123);
	int *abundant_sum = (int *)malloc(sizeof(int) * 28123);
	int *abundant_sum_check = (int *)malloc(sizeof(int) * 28123);
	for (i = 0; i < 28123; i++)
		abundant_sum_check[i] = 0;
	for (i = 0; i < 28123; i++)
	{
		if (is_abundant(i))
			abundant[i] = 1;
		else
			abundant[i] = 0;
	}
	for (i = 0; i < 28123; i++)
	{
		if (abundant[i])
		{
			for (j = 0; j < 28123; j++)
			{
				if (abundant[j])
				{
					abundant_sum[i + j] = 1;
					abundant_sum_check[i + j] = 1;
				}
			}
		}
	}
	for (i = 0; i < 28123; i++)
	{
		if (!abundant_sum_check[i])
			sum += i;
	}
	printf("%d\n", sum);
	return 0;
}
