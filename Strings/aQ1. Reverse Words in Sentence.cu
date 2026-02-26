#include <stdio.h>
#include <string.h>
#include <cuda_runtime.h>

__global__ void reverseWords(char *str, int *starts, int *lengths, int nwords) {

    int tid = blockIdx.x * blockDim.x + threadIdx.x;

    if (tid < nwords) {

        int start = starts[tid];
        int len = lengths[tid];

        for (int i = 0; i < len / 2; i++) {
            char temp = str[start + i];
            str[start + i] = str[start + len - 1 - i];
            str[start + len - 1 - i] = temp;
        }
    }
}

int main() {

    char h_str[] = "CUDA is fun";
    int len = strlen(h_str);

    // Find word start positions and lengths (on CPU)
    int starts[50], lengths[50];
    int nwords = 0;

    int i = 0;
    while (i < len) {
        while (i < len && h_str[i] == ' ')
            i++;

        if (i >= len) break;

        starts[nwords] = i;
        int j = i;

        while (j < len && h_str[j] != ' ')
            j++;

        lengths[nwords] = j - i;
        nwords++;

        i = j;
    }

    char *d_str;
    int *d_starts, *d_lengths;

    cudaMalloc((void**)&d_str, len);
    cudaMalloc((void**)&d_starts, nwords * sizeof(int));
    cudaMalloc((void**)&d_lengths, nwords * sizeof(int));

    cudaMemcpy(d_str, h_str, len, cudaMemcpyHostToDevice);
    cudaMemcpy(d_starts, starts, nwords * sizeof(int), cudaMemcpyHostToDevice);
    cudaMemcpy(d_lengths, lengths, nwords * sizeof(int), cudaMemcpyHostToDevice);

    reverseWords<<<1, nwords>>>(d_str, d_starts, d_lengths, nwords);

    cudaMemcpy(h_str, d_str, len, cudaMemcpyDeviceToHost);

    printf("Output: %s\n", h_str);

    cudaFree(d_str);
    cudaFree(d_starts);
    cudaFree(d_lengths);

    return 0;
}
