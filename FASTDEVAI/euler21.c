#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int main()
{
    int i, j, sum, sum2;
    int amicable[10000];
    int amicable_sum = 0;

    for (i = 1; i < 10000; i++)
    {
        sum = 0;
        for (j = 1; j < i; j++)
        {
            if (i % j == 0)
            {
                sum += j;
            }
        }
        sum2 = 0;
        for (j = 1; j < sum; j++)
        {
            if (sum % j == 0)
            {
                sum2 += j;
            }
        }
        if (sum2 == i && sum != i)
        {
            amicable[i] = 1;
        }
        else
        {
            amicable[i] = 0;
        }
    }

    for (i = 1; i < 10000; i++)
    {
        if (amicable[i] == 1)
        {
            amicable_sum += i;
        }
    }

    printf("%d\n", amicable_sum);

    return 0;
}
