#include <stdio.h>

int main()
{
    int day = 1;
    int month = 1;
    int year = 1900;
    int day_of_week = 1;
    int sundays = 0;

    while (year < 2001)
    {
        if (day == 1 && day_of_week == 0 && year > 1900)
        {
            sundays++;
        }

        day_of_week++;
        day_of_week %= 7;

        day++;

        if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12)
        {
            if (day > 31)
            {
                day = 1;
                month++;
            }
        }
        else if (month == 4 || month == 6 || month == 9 || month == 11)
        {
            if (day > 30)
            {
                day = 1;
                month++;
            }
        }
        else if (month == 2)
        {
            if (year % 4 == 0)
            {
                if (day > 29)
                {
                    day = 1;
                    month++;
                }
            }
            else
            {
                if (day > 28)
                {
                    day = 1;
                    month++;
                }
            }
        }

        if (month > 12)
        {
            month = 1;
            year++;
        }
    }

    printf("%d\n", sundays);

    return 0;
}
