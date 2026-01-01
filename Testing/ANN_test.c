#include <stdio.h>
#include <stdint.h>

#define M 3
#define FRAC_BITS 30   // Q2.30

// ---------- Fixed-point helpers ----------
int32_t float_to_q230(float x) {
    return (int32_t)(x * (1LL << FRAC_BITS));
}

float q230_to_float(int32_t x) {
    return (float)x / (1LL << FRAC_BITS);
}

// ---------- ReLU ----------
int64_t relu(int64_t x) {
    return (x > 0) ? x : 0;
}

// ---------- Quantizer (Q2.30) ----------
int32_t quantize_q230(int64_t acc) {
    return (int32_t)(acc >> FRAC_BITS);
}

// ---------- ANN Reference Model ----------
int32_t ANN_model_q230(float x[M], float w[M]) {

    int32_t fx[M], fw[M];
    int64_t mac = 0;

    // Convert inputs and weights to Q2.30
    for (int i = 0; i < M; i++) {
        fx[i] = float_to_q230(x[i]);
        fw[i] = float_to_q230(w[i]);
    }

    // MAC stage
    for (int i = 0; i < M; i++) {
        mac += (int64_t)fx[i] * fw[i];
    }

    // ReLU
    mac = relu(mac);

    // Quantizer (Q2.30 output)
    return quantize_q230(mac);
}

// ---------- Test ----------
int main() {

    float x[M] = {0.125, 0.25, 0.375};
    float w[M] = {0.25, 0.375, 0.125};

    int32_t result = ANN_model_q230(x, w);

    printf("ANN Output (Q2.30 Decimal): %d\n", result);
    printf("ANN Output (Hex)         : 0x%08X\n", result);
    printf("ANN Output (Float)       : %f\n", q230_to_float(result));

    return 0;
}
