# ORIGINAL HAD "#include <iostream>" instead of <iostrem.h>

#include <string.h>
#include <algorithm.h>

using namespace std;

bool isPalindrome(int n) {
	string s = to_string(n);
	string s2 = s;
	reverse(s2.begin(), s2.end());
	return s == s2;
}

int main() {
	int max = 0;
	for (int i = 100; i < 1000; i++) {
		for (int j = 100; j < 1000; j++) {
			if (isPalindrome(i*j)) {
				if (i*j > max) {
					max = i*j;
				}
			}
		}
	}
	cout << max << endl;
	return 0;
}
