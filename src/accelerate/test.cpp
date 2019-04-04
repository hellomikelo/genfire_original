#include <iostream>
#include "cross.h"

using namespace std;
int main(){
int A[3] = {1,1,1};
int B[3] = {0,1,0};
//int results[3] = {0,0,0};
int* result = cross<int>((int*)&A[0],(int*)&B[0]);
cout << result[0] << endl;
cout << result[1] << endl;
cout << result[2] << endl;
return 0;
}
