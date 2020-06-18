#include <stdio.h>

int main(void)
{
   float income, tax;
   printf("Please enter your taxable income: ");
   scanf("%f", &income);

   if (income < 750.0f) 
      tax = 0.01f * income;
   else if (income < 2250.0f)
      tax = 7.50f + 0.02f * income;
   else if (income < 3750.0f)
      tax = 37.50f + 0.03f * income;
   else if (income < 5250.0f)
      tax = 82.50f + 0.04f * income;
   else if (income < 7000.0f)
      tax = 142.50f + 0.05f * income;
   else 
      tax = 230.0f + 0.06f * income;

   printf("You owe R%0.2f in tax\n", tax);

   return 0;
}