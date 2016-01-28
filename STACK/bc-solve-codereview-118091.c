#include <iostream>
#include <chrono>
using namespace std;

int main() {

	double a[10000],b[10000];
	for(int i=0;i<10000;i++){
		b[i]=(double)(rand()+1)/(double)(RAND_MAX+1);
		a[i]=b[i];
	}
	auto start = chrono::steady_clock::now();

	    int x1=0,x2=0,i1,index; 
      for ( i1 = 1; i1 <= 10000; i1++){
                 for ( index = 0; index < 10000; index++){
                 
    
                    x1++;
                    if(x1>100){
                        x1=0;
                        x2++;
                     }
                     a[index] = 0;
                     if (x1 > 10)
                     {
                         a[index] += a[index - 10*1];
                     }
                     if (x2 < 95)
                     {
                         a[index] += a[index + 5*100];
                     }
                 }
             }
auto end = chrono::steady_clock::now();
auto diff = end - start;

cout << "method 8: " << chrono::duration <double, nano> (diff).count() << " ns" << endl;


				double temp;
				for(int i=0;i<10000;i++){
	    		temp=a[i];
				a[i]=b[i];
				b[i]=temp;
	        }
				
	start = chrono::steady_clock::now();					   
          for ( i1 = 1; i1 <= 10000; i1++){
			    index=-1;
                 
                      for ( x2 = 0; x2 < 100; x2++){
						  for ( x1 = 0; x1 < 100; x1++){
                 
                    index++;
                     a[index] = 0;
                     if (x1 > 10){
                         a[index] += a[index - 10*1];
                     }
                     if (x2 < 95){
                         a[index] += a[index + 5*100];
                     }
                 }
             }
		  }
end = chrono::steady_clock::now();
diff = end - start;

cout << "method 6 " << chrono::duration <double, nano> (diff).count() << " ns" << endl;
	return 0;
}
