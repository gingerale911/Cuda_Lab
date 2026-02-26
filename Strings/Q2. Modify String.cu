#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>

__global__ void buildRS(char *S, char *RS, int n) {

    int i = blockIdx.x * blockDim.x + threadIdx.x;

    if (i < n) {

        // Starting index for this substring
        int start = i*n - (i*(i-1))/2;

        int len = n - i;

        for (int j = 0; j < len; j++) {
            RS[start + j] = S[j];
        }
    }
}

int main() {

    char h_S[] = "PCAP";
    int n = strlen(h_S);

    int out_len = n*(n+1)/2;

    char *d_S, *d_RS;
    char *h_RS = (char*)malloc(out_len + 1);

    cudaMalloc((void**)&d_S, n);
    cudaMalloc((void**)&d_RS, out_len);

    cudaMemcpy(d_S, h_S, n, cudaMemcpyHostToDevice);

    buildRS<<<1, n>>>(d_S, d_RS, n);

    cudaMemcpy(h_RS, d_RS, out_len, cudaMemcpyDeviceToHost);

    h_RS[out_len] = '\0';

    printf("Input  : %s\n", h_S);
    printf("Output : %s\n", h_RS);

    cudaFree(d_S);
    cudaFree(d_RS);
    free(h_RS);

    return 0;
}
