#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>

__global__ void buildPattern(char *Sin, char *T, int len) {

    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < len) {

        // Starting index in output
        int start = i * (i + 1) / 2;

        for (int j = 0; j <= i; j++) {
            T[start + j] = Sin[i];
        }
    }
}

int main() {

    char h_Sin[] = "Hai";
    int len = strlen(h_Sin);

    int out_len = len * (len + 1) / 2;

    char *d_Sin, *d_T;
    char *h_T = (char*)malloc(out_len + 1);

    cudaMalloc((void**)&d_Sin, len);
    cudaMalloc((void**)&d_T, out_len);

    cudaMemcpy(d_Sin, h_Sin, len, cudaMemcpyHostToDevice);

    buildPattern<<<1, len>>>(d_Sin, d_T, len);

    cudaMemcpy(h_T, d_T, out_len, cudaMemcpyDeviceToHost);

    h_T[out_len] = '\0';

    printf("Input  : %s\n", h_Sin);
    printf("Output : %s\n", h_T);

    cudaFree(d_Sin);
    cudaFree(d_T);
    free(h_T);

    return 0;
}
