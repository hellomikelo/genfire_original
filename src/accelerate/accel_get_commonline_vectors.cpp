#include "mex.h"
#include "cross.h"
#include "matrix_33_31.h"
#include "matrix_33_31_tmult.h"

void mexFunction(int nlhs, mxArray *plhs[],int nrhs, const mxArray *prhs[]){
    double *Matrix1, *Matrix2, *invnormvec1, *invnormvec2;   
    double ZeroNormal[] = {0,0,1};
    plhs[0] = mxCreateDoubleMatrix(3,1,mxREAL);
    plhs[1] = mxCreateDoubleMatrix(3,1,mxREAL);
    Matrix1 = mxGetPr(prhs[0]);
    Matrix2 = mxGetPr(prhs[1]);
    invnormvec1 = mxGetPr(plhs[0]);
    invnormvec2 = mxGetPr(plhs[1]);
    
    double normvec1[] = {0,0,0};
    double normvec2[] = {0,0,0};
    double commonvec[] = {0,0,0};
    
    matrix_33_31(Matrix1, ZeroNormal, normvec1);
    matrix_33_31(Matrix2, ZeroNormal, normvec2);
    cross(normvec1, normvec2, commonvec);
    matrix_33_31_tmult(Matrix1,commonvec, invnormvec1);
    matrix_33_31_tmult(Matrix2,commonvec, invnormvec2);
}