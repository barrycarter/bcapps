#include <iostream>
#include <iomanip>
#include <cmath>
#include <vector>

using namespace std;

int main() {
  int attackers, defenders, i, j;
  double arun=0.;
  //  double dl2, el1, al2;
  cout << "Enter number of attackers: ";
  cin >> attackers;
  cout << "Enter number of defenders: ";
  cin >> defenders;

  printf("\n");

  // I use the highest number as an index, so adding 1
  double odds[attackers+1][defenders+1];

  // because I'm going to print the "defense wins" section backwards,
  // I'll need to store values of running odds for defense
  double druns[defenders+1];

  // initialize all elts to 0 (annoyed C++ doesnt do this):
  // "variable-sized object `odds' may not be initialized"
  for (i=0; i<=attackers; i++) {
    for (j=0; j<=defenders; j++) {
      odds[i][j] = 0.;
    }
  }

  // the starting condition is true by definition
  odds[attackers][defenders] = 1.;

  for (i = attackers; i>=1; i--) {
    for (j = defenders; j>=1; j--) {

      // special case: 1 attacker, 1 defender
      if (i==1 && j==1) {
	odds[1][0] += 15./36.*odds[1][1];
	odds[0][1] += 21./36.*odds[1][1];
	continue;
      }

      // special case: 2 attackers, 1 defender
      if (i==2 && j==1) {
	odds[2][0] += 125./216.*odds[2][1];
	odds[1][1] += 91./216.*odds[2][1];
	continue;
      }

      // special case 1 attackers, 2+ defenders

      if (i==1 && j>=2) {
	odds[1][j-1] += 55./216.*odds[i][j];
	odds[0][j] += 161./216.*odds[i][j];
	continue;
      }


      // special case 3+ attackers, 1 defender
      if (j==1 && i>=3) {
	odds[i][0] += odds[i][j]*855./1296.;
	odds[i-1][1] += odds[i][j]*441./1296.;
	continue;
      }

      // special case 2 attackers, 2+ defenders
      if (i==2 && j>=2) {
	odds[2][j-2] += 295./1296.*odds[i][j];
	odds[1][j-1] += 420./1296.*odds[i][j];
	odds[0][j] += 581./1296.*odds[i][j];
	continue;
      }

      // general case
      odds[i][j-2] += 2890./7776.*odds[i][j];
      odds[i-1][j-1] += 2611./7776.*odds[i][j];
      odds[i-2][j] += 2275./7776.*odds[i][j];
    }
  }

  for (i = attackers; i>=1; i--) {
    arun += odds[i][0];
    printf("A: %2d | D: 0 | Odds: %.4f%% | Running odds: %.4f%%\n", i, odds[i][0]*100., arun*100.);
  }

  printf("------|------|---------------|-----------------------\n");

  // compute druns
  druns[defenders] = odds[0][defenders];
  for (j = defenders-1; j>=1; j--) {druns[j] = druns[j+1] + odds[0][j];}

  for (j = 1; j<=defenders; j++) {
    printf("A: 0 | D: %2d | Odds: %.4f%% | Running odds: %.4f%%\n", j, odds[0][j]*100., druns[j]*100.);
  }

  return 0;
}
