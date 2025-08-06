#ifndef INFERENCE_ENGINE_H
#define INFERENCE_ENGINE_H

#ifdef __cplusplus
extern "C" {
#endif

#include <stddef.h>
#include <stdint.h>

/**
 * Opaque handle to the inference engine
 */
typedef void* EngineHandle;

/**
 * Initialize the inference engine
 * @param arena_size Size of memory arena for TensorFlow Lite operations
 * @return Handle to the engine, or NULL on failure
 */
EngineHandle inference_init(size_t arena_size);

/**
 * Cleanup and destroy the inference engine
 */
void inference_deinit(void);

/**
 * Get pointer to input buffer for the first input tensor
 * @return Pointer to float array for input data
 */
float* inference_input_buffer_ptr(void);

/**
 * Get length of input buffer
 * @return Number of float elements in input buffer
 */
size_t inference_input_len(void);

/**
 * Get pointer to output buffer for the first output tensor
 * @return Pointer to float array for output data
 */
float* inference_output_buffer_ptr(void);

/**
 * Get length of output buffer
 * @return Number of float elements in output buffer
 */
size_t inference_output_len(void);

/**
 * Run inference on the loaded model
 * @return 0 on success, -1 on failure
 */
int8_t inference_invoke(void);

#ifdef __cplusplus
}
#endif

#endif /* TFLM_INFERENCE_H */