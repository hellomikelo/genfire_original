// multiplies a 3x3 matrix by a 3x1 vector
template <typename T>
inline void matrix_33_31(const T* A, const T* B, T* C){
    C[0] = A[0] * B[0] + A[3] * B[1] + A[6] * B[2];
    C[1] = A[1] * B[0] + A[4] * B[1] + A[7] * B[2];
    C[2] = A[2] * B[0] + A[5] * B[1] + A[8] * B[2];
}


