#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_log.h"
#include "tensorflow/lite/micro/system_setup.h"
#include "tensorflow/lite/schema/schema_generated.h"
#include "model/model.h"

extern "C" {
    // Opaque pointer types for C interface
    typedef struct TFLMInterpreter TFLMInterpreter;
    
    // Initialize TFLM
    void tflm_init() {
        tflite::InitializeTarget();
    }
    
    // Create interpreter with model from your generated model.cc
    TFLMInterpreter* tflm_create_interpreter_from_model(unsigned char* tensor_arena, 
                                                       size_t arena_size) {
        // Get model from the generated model.cc file
        const tflite::Model* model = tflite::GetModel(models_audio_tflite);
        if (model->version() != TFLITE_SCHEMA_VERSION) {
            MicroPrintf("Model provided is schema version %d not equal to supported version %d.",
                       model->version(), TFLITE_SCHEMA_VERSION);
            return nullptr;
        }
        
        // Create mutable resolver and add only the ops your model needs
        // For micro_speech model, you typically need:
        static tflite::MicroMutableOpResolver<4> resolver;
        resolver.AddDepthwiseConv2D();
        resolver.AddFullyConnected();
        resolver.AddSoftmax();
        resolver.AddReshape();
        
        // Create interpreter
        static tflite::MicroInterpreter* interpreter = new tflite::MicroInterpreter(
            model, resolver, tensor_arena, arena_size);
        
        // Allocate tensors
        TfLiteStatus allocate_status = interpreter->AllocateTensors();
        if (allocate_status != kTfLiteOk) {
            MicroPrintf("AllocateTensors() failed");
            return nullptr;
        }
        
        return reinterpret_cast<TFLMInterpreter*>(interpreter);
    }
    
    // Get input tensor
    float* tflm_get_input_buffer(TFLMInterpreter* interp, int input_index) {
        auto* interpreter = reinterpret_cast<tflite::MicroInterpreter*>(interp);
        TfLiteTensor* input = interpreter->input(input_index);
        return input->data.f;
    }
    
    // Get output tensor
    float* tflm_get_output_buffer(TFLMInterpreter* interp, int output_index) {
        auto* interpreter = reinterpret_cast<tflite::MicroInterpreter*>(interp);
        TfLiteTensor* output = interpreter->output(output_index);
        return output->data.f;
    }
    
    // Run inference
    int tflm_invoke(TFLMInterpreter* interp) {
        auto* interpreter = reinterpret_cast<tflite::MicroInterpreter*>(interp);
        TfLiteStatus invoke_status = interpreter->Invoke();
        return (invoke_status == kTfLiteOk) ? 0 : -1;
    }
    
    // Get input/output dimensions
    int tflm_get_input_size(TFLMInterpreter* interp, int input_index) {
        auto* interpreter = reinterpret_cast<tflite::MicroInterpreter*>(interp);
        TfLiteTensor* input = interpreter->input(input_index);
        int size = 1;
        for (int i = 0; i < input->dims->size; i++) {
            size *= input->dims->data[i];
        }
        return size;
    }
    
    int tflm_get_output_size(TFLMInterpreter* interp, int output_index) {
        auto* interpreter = reinterpret_cast<tflite::MicroInterpreter*>(interp);
        TfLiteTensor* output = interpreter->output(output_index);
        int size = 1;
        for (int i = 0; i < output->dims->size; i++) {
            size *= output->dims->data[i];
        }
        return size;
    }
}