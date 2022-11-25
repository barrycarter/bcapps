#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#define MAX_DIGITS 200

int main(int argc, char *argv[])
{
    int i, j, k, carry, sum, n;
    int digits[MAX_DIGITS];

    if (argc != 2) {
        printf("Usage: %s <n>\n", argv[0]);
        return 1;
    }

    n = atoi(argv[1]);

    memset(digits, 0, sizeof(digits));
    digits[0] = 1;

    for (i = 2; i <= n; i++) {
        carry = 0;
        for (j = 0; j < MAX_DIGITS; j++) {
            sum = digits[j] * i + carry;
            digits[j] = sum % 10;
            carry = sum / 10;
        }
    }

    for (i = MAX_DIGITS - 1; i >= 0; i--) {
        if (digits[i] != 0) {
            break;
        }
    }

    for (j = 0; j <= i; j++) {
        printf("%d", digits[j]);
    }
    printf("\n");

    return 0;
}
