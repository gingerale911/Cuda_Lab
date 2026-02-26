#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>

__global__ void repeatString(char *Sin, char *Sout, int len, int N) {

    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < len) {
        for (int k = 0; k < N; k++) {
            Sout[i + k * len] = Sin[i];
        }
    }
}

int main() {

    char h_Sin[] = "Hai";
    int N = 3;

    int len = strlen(h_Sin);
    int out_len = len * N;

    char *d_Sin, *d_Sout;
    char *h_Sout = (char*)malloc(out_len + 1);

    cudaMalloc((void**)&d_Sin, len);
    cudaMalloc((void**)&d_Sout, out_len);

    cudaMemcpy(d_Sin, h_Sin, len, cudaMemcpyHostToDevice);

    repeatString<<<1, len>>>(d_Sin, d_Sout, len, N);

    cudaMemcpy(h_Sout, d_Sout, out_len, cudaMemcpyDeviceToHost);

    h_Sout[out_len] = '\0';

    printf("Output: %s\n", h_Sout);

    cudaFree(d_Sin);
    cudaFree(d_Sout);
    free(h_Sout);

    return 0;
}
