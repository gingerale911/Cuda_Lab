#include<stdio.h>
#include<string.h>
#include<cuda_runtime.h>

__global__ void  countw(char *sentence, char* word, int wlen, int slen, int *count){
    int i = blockIdx.x * blockDim.x +threadIdx.x;

    if(i <= slen - wlen){
        int match = 1;
        for(int j=0; j < wlen; j++){
            if(sentence[i+j] != word[j]){
                match = 0;
                break;
            }
        }
        if(match){
            atomicAdd(count, 1);
        }
    }
}

int main(){
    char h_sent[] = "Aak is Aak Aak";
    char h_wod[] = "Aak";

    int slen = strlen(h_sent);
    int wlen = strlen(h_wod);

    char *d_sent, *d_wod;
    int *d_count;
    int h_count=0;

    cudaMalloc((void**)&d_sent, slen * sizeof(char));
    cudaMalloc((void**)&d_wod, wlen * sizeof(char));
    cudaMalloc((void**)&d_count, sizeof(int));

    cudaMemcpy(d_sent, h_sent, slen * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_wod, h_wod, wlen * sizeof(char), cudaMemcpyHostToDevice);
    cudaMemcpy(d_count, &h_count, sizeof(int), cudaMemcpyHostToDevice);

    countw<<<(slen+255)/256, 256>>>(d_sent, d_wod, wlen, slen, d_count);

    cudaMemcpy(&h_count, d_count, sizeof(int), cudaMemcpyDeviceToHost);

    printf("count = %d\n", h_count);
}
