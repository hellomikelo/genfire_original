#include "mex.h"
#include "matrix_33_31_tmult.h"

//computes matrix product of the transpose of 3x3 matrix A and 3x1 vector B. 
//NO BOUNDS CHECKING IS PERFORMED. BE SURE YOUR INPUTS FROM MATLAB
//ARE CORRECT
void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[]){
    double *A,*B,*C;    
    plhs[0] = mxCreateDoubleMatrix(3,1,mxREAL);
    A = mxGetPr(prhs[0]);
    B = mxGetPr(prhs[1]);
    C = mxGetPr(plhs[0]);
    matrix_33_31_tmult<double>(A,B,C);   
}