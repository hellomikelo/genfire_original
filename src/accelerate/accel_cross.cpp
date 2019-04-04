#include "mex.h"
#include "cross.h"

//computes cross product of two vectors quickly. 
//NO BOUNDS CHECKING IS PERFORMED. BE SURE YOUR INPUTS FROM MATLAB
//ARE TWO 3-ELEMENT COLUMN VECTORS
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[]){
    double *A,*B,*C;    
    plhs[0] = mxCreateDoubleMatrix(3,1,mxREAL);
    A = mxGetPr(prhs[0]);
    B = mxGetPr(prhs[1]);
    C = mxGetPr(plhs[0]);
    cross<double>(A,B,C);   
}