#include <iostream>
#include <iomanip>
#include <cmath>
#include <vector>

using namespace std;

class battle {
    public:
        int attackers;
        int defenders;
        float odds;
               battle (int a, int d, float o) {
            attackers = a;
            defenders = d;
            odds = o;
        }
};

void submain(int, int);
void cleaner(vector<battle>&);
void sorter(battle);
void a1d1(battle);
void a1d2(battle);
void a2d1(battle);
void a2d2(battle);
void a3d1(battle);
void a3d2(battle);
void giveoutput();
int oddssize();

vector<float> attack_wins, defend_wins;
vector<battle> outcomes;

int main() {
  int attackers, defenders, i, j;
  //  double dl2, el1, al2;
  cout << "Enter number of attackers: ";
  cin >> attackers;
  cout << "Enter number of defenders: ";
  cin >> defenders;

  printf("\n");

  // I use the highest number as an index, so adding 1
  double odds[attackers+1][defenders+1];

  // initialize all elts to 0 (annoyed C++ doesnt do this)
  for (i=0; i<=attackers; i++) {
    for (j=0; j<=defenders; j++) {
      odds[i][j] = 0.;
    }
  }

  // the starting condition is true by definition
  odds[attackers][defenders] = 1.;

  for (i = attackers; i>=1; i--) {
    for (j = defenders; j>=1; j--) {

      // short-circuit: if 0 odds of reaching this state, just move on
      // TODO: shouldnt test float to 0
      if (odds[i][j] == 0.) {
	printf("odds[%d][%d] = 0, so ignoring\n", i, j);
	continue;
      }

      // special case: 1 attacker, 1 defender
      if (i==1 && j==1) {
	odds[1][0] += 15./36.*odds[1][1];
	odds[0][1] += 21./36.*odds[1][1];
	printf("EPSILON odds[%d][%d] = %f\n", i, j, odds[i][j]);
	printf("SETTING: odds[%d][%d] = %f, odds[%d][%d] = %f\n", 1, 0, odds[1][0], 0, 1, odds[0][1]);
	continue;
      }

      // special case: 2 attackers, 1 defender
      if (i==2 && j==1) {
	odds[2][0] += 125./216.*odds[2][1];
	odds[1][1] += 91./216.*odds[2][1];
	printf("ZETA odds[%d][%d] = %f\n", i, j, odds[i][j]);
	printf("SETTING: odds[%d][%d] = %f, odds[%d][%d] = %f\n", 2, 0, odds[2][0], 1, 1, odds[1][1]);
	continue;
      }

      // special case 1 attackers, 2+ defenders
      // note: this case is NOT in
      // http://www.strategygamenetwork.com/statistics.html#q9

      if (i==1 && j>=2) {

	// defender loses one
	odds[1][j-1] += 55./216.*odds[i][j];

	// attacker loses one
	odds[0][j] += 161./216.*odds[i][j];

	printf("ALPHA odds[%d][%d] = %f\n", i, j, odds[i][j]);

	printf("SETTING: odds[%d][%d] = %f, odds[%d][%d] = %f\n", 1, j-1, odds[1][j-1], 0, j, odds[0][j]);

	continue;
      }


      // special case 3+ attackers, 1 defender
      if (j==1 && i>=3) {

	// defender loses 1
	odds[i][0] += odds[i][j]*855./1296.;
    
	// attacker loses 1
	odds[i-1][1] += odds[i][j]*441./1296.;

	printf("BETA odds[%d][%d] = %f\n", i, j, odds[i][j]);

	printf("SETTING: odds[%d][%d] = %f, odds[%d][%d] = %f\n", i, 0, odds[i][0], i-1, 1, odds[i-1][1]);

	continue;
      }

      // special case 2 attackers, 2+ defenders
      if (i==2 && j>=2) {
	
	// defender loses 2
	odds[2][j-2] += 295./1296.*odds[i][j];

	// each lose 1
	odds[1][j-1] += 420./1296.*odds[i][j];

	// attacker loses 2
	odds[0][j] += 581./1296.*odds[i][j];

	printf("GAMMA odds[%d][%d] = %f\n", i, j, odds[i][j]);
	printf("SETTING: odds[%d][%d] = %f, odds[%d][%d] = %f, odds[%d][%d] = %f\n", 2, j-2, odds[2][j-2], 1, j-1, odds[1][j-1], 0, j, odds[0][j]);

	continue;

      }

      // defender loses two
      odds[i][j-2] += 2890./7776.*odds[i][j];

      // each loses one
      odds[i-1][j-1] += 2611./7776.*odds[i][j];

      // attacker loses two
      odds[i-2][j] += 2275./7776.*odds[i][j];

	printf("DELTA odds[%d][%d] = %f\n", i, j, odds[i][j]);
	printf("SETTING: odds[%d][%d] = %f, odds[%d][%d] = %f, odds[%d][%d] = %f\n", i, j-2, odds[i][j-2], i-1, j-1, odds[i-1][j-1], i-2, j, odds[i-2][j]);

    }
  }

  for (i = attackers; i>=1; i--) {
    printf("A: %d, D: 0, odds: %f\n", i, odds[i][0]);
  }

  printf("\n");

  for (j = 1; j<=defenders; j++) {
    printf("A: 0, D: %d, odds: %f\n", j, odds[0][j]);
  }

  exit(-1);


    // compute odds for attacker each number of attackers/defenders
    // see http://www.strategygamenetwork.com/statistics.html#q9 but
    // can also compute the numbers below yourself

    // no defenders = you have won, no attackers = you have lost
  //    for (i=1; i<=attackers; i++) {odds[i][0] = 1.;}
  //    for (i=1; i<=defenders; i++) {odds[0][i] = 0.;}

    // special case for one defender
  //    for (i=1; i<=attackers; i++) {
  //      odds[i][1] = 855./1296 + 441./1296*odds[i-1][1];
  //    }

    // all other cases
  //    for (i=2; i<=attackers; i++) {
  //      for (j=2; j<=defenders; j++) {
  //	odds[i][j] = 2890./7776*odds[i][j-2] + 2611./7776*odds[i-1][j-1] +
  //	  2275./7776*odds[i-2][j];
  //      }
  //    }

  //    for (i=0; i<=attackers; i++) {
  //      for (j=0; j<=defenders; j++) {
  //	printf("%d %d: %f\n", i, j, odds[i][j]);
  //      }
  //    }

  //    submain(attackers, defenders);

  //    giveoutput();
}

// The main part of the program
// Has the list of possibilities condensed, then has each possibility ran
void submain(int attackers, int defenders){
    attack_wins = vector<float>(attackers,0);
    defend_wins = vector<float>(defenders,0);
    outcomes.push_back(battle(attackers, defenders, 100));

    while (!outcomes.empty()){
        //cerr << loopnum << endl;
        vector<battle> list = outcomes;
        outcomes.clear();
        cleaner(list);

        for (int l = 0; l < list.size(); l++){
            //cerr << "    " << l << endl;
            sorter(list[l]);
        }
    }
}

// Condenses the list of outcomes
// The sum of the attackers and defenders needs to equal the static number,
// otherwise it's kept to the side
void cleaner(vector<battle>& list){
    static int count;
    static bool fastshrink = 1;
    count -= 1 + fastshrink;

    if(count < list[0].attackers + list[0].defenders){
        count = list[0].attackers + list[0].defenders;
        fastshrink = 1;
    }
    if(min(list.back().attackers, list[0].defenders) <= 1)
        fastshrink = 0;

    for (int l1 = 0; l1 < list.size(); l1++){
        battle& b1 = list[l1];

        if (b1.attackers + b1.defenders < count) {
            outcomes.push_back(b1);
            list.erase(list.begin() + l1--);
            continue;
            }

        for (int l2 = l1+1; l2 < list.size(); l2++){
            battle b2 = list[l2];
            if (b1.attackers == b2.attackers && b1.defenders == b2.defenders){
                b1.odds += b2.odds;
                list.erase(list.begin() + l2--);
            }
        }
    }
}

// Either puts the odds into the correct array (if the battle is over)
// or decides which function to use (if the battle is still going on)
void sorter(battle fight) {
  //    loopnum++;
    switch(fight.attackers) {
        case 0:
            defend_wins[fight.defenders-1] = fight.odds;
            break;
        case 1:
            switch(fight.defenders) {
                case 0:
                    attack_wins[fight.attackers-1] = fight.odds;
                    break;
                case 1:
                    a1d1(fight);
                    break;
                default:
                    a1d2(fight);
                    break;
            }
            break;
        case 2:
            switch(fight.defenders) {
                case 0:
                    attack_wins[fight.attackers-1] = fight.odds;
                    break;
                case 1:
                    a2d1(fight);
                    break;
                default:
                    a2d2(fight);
                    break;
            }
            break;
        default:
            switch(fight.defenders) {
                case 0:
                    attack_wins[fight.attackers - 1] = fight.odds;
                    break;
                case 1:
                    a3d1(fight);
                    break;
                default:
                    a3d2(fight);
                    break;
            }
            break;
    }
}

// Individual battles' functions
// Figures out the number of times that the attacker/defender wins the first time it's called,
// and creates new possibilities to be condensed based on those numbers
void a1d1( battle fight) {
    static int ATK = 0;
    static int DEF = 0;
    static int SUM = 0;

    if(!SUM) {
        for(int a1 = 1; a1 <= 6; a1++){
            for(int d1 = 1; d1 <= 6; d1++){
                SUM++;
                if(a1 > d1)
                    ATK++;
                else
                    DEF++;
            }
        }
    }

    outcomes.push_back(battle(fight.attackers, fight.defenders - 1, fight.odds * ATK /SUM));
    outcomes.push_back(battle(fight.attackers - 1, fight.defenders, fight.odds * DEF / SUM));
}

void a1d2(battle fight) {
    static int ATK = 0;
    static int DEF = 0;
    static int SUM = 0;

    if(!SUM) {
        for(int a1=1;a1<=6;a1++){
            for(int d1=1;d1<=6;d1++){
                for(int d2=1;d2<=6;d2++){
                    int D1=max(d1,d2);
                    SUM++;
                    if(a1>D1)
                        ATK++;
                    else
                        DEF++;
                }
            }
        }
    }

    outcomes.push_back(battle(fight.attackers, fight.defenders - 1, fight.odds * ATK / SUM));
    outcomes.push_back(battle(fight.attackers - 1, fight.defenders, fight.odds * DEF / SUM));
}

void a2d1( battle fight) {
    static int ATK = 0;
    static int DEF = 0;
    static int SUM = 0;

    if(!SUM) {
        for(int a1 = 1; a1 <= 6; a1++){
            for(int a2 = 1; a2 <= 6; a2++){
                for(int d1 = 1; d1 <= 6; d1++){
                    int A1= max(a1, a2);
                    SUM++;
                    if(A1 > d1)
                        ATK++;
                    else
                        DEF++;
                }
            }
        }
    }

    outcomes.push_back(battle(fight.attackers, fight.defenders - 1, fight.odds * ATK / SUM));
    outcomes.push_back(battle(fight.attackers - 1, fight.defenders, fight.odds * DEF / SUM));
}

void a2d2(battle fight) {
    static int ATK = 0;
    static int TIE = 0;
    static int DEF = 0;
    static int SUM = 0;

     if(!SUM) {
        for(int a1=1; a1 <= 6; a1++){
            for(int a2 = 1; a2 <= 6; a2++){
                for(int d1 = 1; d1 <= 6; d1++){
                    for(int d2 = 1; d2 <= 6; d2++){
                        int A1 = max(a1, a2);
                        int A2 = min( a1, a2);
                        int D1 = max(d1, d2);
                        int D2 = min(d1, d2);
                        switch((A1 > D1) + (A2 > D2)){
                            case 0:
                                DEF++;
                                SUM++;
                                break;
                            case 1:
                                TIE++;
                                SUM++;
                                break;
                            case 2:
                                ATK++;
                                SUM++;
                                break;
                        }
                    }
                }
            }
        }
    }

    outcomes.push_back(battle(fight.attackers, fight.defenders - 2, fight.odds * ATK / SUM));
    outcomes.push_back(battle(fight.attackers - 1, fight.defenders - 1, fight.odds * TIE / SUM));
    outcomes.push_back(battle(fight.attackers - 2, fight.defenders, fight.odds * DEF / SUM));
}

void a3d1( battle fight) {
    static int ATK = 0;
    static int DEF = 0;
    static int SUM = 0;

    if(!SUM) {
        for(int a1=1; a1 <= 6; a1++){
            for(int a2 = 1; a2 <= 6; a2++){
                for(int a3 = 1; a3 <= 6; a3++){
                    for(int d1 = 1; d1 <= 6; d1++){
                        SUM++;
                        int A1 = max(a1, max(a2, a3));
                        if(A1 > d1)
                            ATK++;
                        else
                            DEF++;
                    }
                }
            }
        }
    }

    outcomes.push_back(battle(fight.attackers, fight.defenders - 1, fight.odds * ATK / SUM));
    outcomes.push_back(battle(fight.attackers - 1, fight.defenders, fight.odds * DEF / SUM));
}

void a3d2(battle fight) {
    static int ATK = 0;
    static int TIE = 0;
    static int DEF = 0;
    static int SUM = 0;

    if(!SUM) {
        for(int a1=1; a1 <= 6; a1++){
            for(int a2 = 1; a2 <= 6; a2++){
                for(int a3 = 1; a3 <= 6; a3++){
                    for(int d1 = 1; d1 <= 6; d1++){
                        for(int d2 = 1; d2 <= 6; d2++){
                            int A1 = max(a1, max(a2, a3));
                            int A2;
                            int D1 = max(d1, d2);
                            int D2 = min(d1, d2);

                            if(a1 == A1)
                                A2 = max(a2, a3);
                            else if(a2 == A1)
                                A2 = max(a1, a3);
                            else
                                A2 = max(a1, a2);

                            switch((A1 <= D1) + (A2 <= D2)){
                                case 2:
                                    DEF++;
                                    SUM++;
                                    break;
                                case 1:
                                    TIE++;
                                    SUM++;
                                    break;
                                case 0:
                                    ATK++;
                                    SUM++;
                                    break;
                            }
                        }
                    }
                }
            }
        }
    }

    outcomes.push_back(battle(fight.attackers, fight.defenders - 2, fight.odds * ATK / SUM));
    outcomes.push_back(battle(fight.attackers - 1, fight.defenders - 1, fight.odds * TIE / SUM));
    outcomes.push_back(battle(fight.attackers - 2, fight.defenders, fight.odds * DEF / SUM));
}

// Prints the results on the screen
void giveoutput() {
    cout << fixed << setprecision(4) << endl;
    float odds = 0;
    int atks = int(2 + floor(log(attack_wins.size()) / log(10)));
    int defs = int(2 + floor(log(defend_wins.size()) / log(10)));
    int odd = oddssize();

    for(int loop = attack_wins.size()-1; loop >= 0; loop--) {
        cout << "A:" << setw(atks) << loop+1;
        cout << " | D:" << setw(defs) << 0 << " | Odds: ";
        cout << setw(odd) << attack_wins[loop] << "%";
        odds += attack_wins[loop];
        cout << " | Running odds: " << setw(7) << odds << "%" << endl;
    }

    //cout << "------|-------|---------------" << endl;
    for (int l = atks + 3; l > 0; l--){
        cout << "-";
    }
    cout << "|";
    for (int l = defs + 4; l > 0; l--){
        cout << "-";
    }
    cout << "|";
    for (int l = odd + 8; l >= 0; l--){
        cout << "-";
    }
    cout << "|-----------------------" << endl;
    odds = 100 - odds;

    for(int loop = 0; loop < defend_wins.size(); loop++) {
        cout << "A:" << setw(atks) << 0 << " | D:";
        cout << setw(atks) << loop+1 << " | Odds: ";
        cout << setw(odd) << defend_wins[loop] << "%";
        cout << " | Running odds: " << setw(7) << odds << "%" << endl;
        odds -= defend_wins[loop];
    }
    cout << endl;
}

int oddssize(){
    for (int l = 0; l < attack_wins.size(); l++){
        if (attack_wins[l] >= 10)
            return 7;
    }

    for (int l = 0; l < defend_wins.size(); l++){
        if (defend_wins[l] >= 10)
            return 7;
    }

    return 6;

}
