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
        
        // Create mutable resolver and add the ops your model needs
        // Based on your model, it appears to use audio processing ops
        // You may need to adjust this based on your specific model requirements
        static tflite::MicroMutableOpResolver<20> resolver;
        
        // Common ops for audio models
        resolver.AddReshape();
        resolver.AddCast();
        resolver.AddStridedSlice();
        resolver.AddConcatenation();
        resolver.AddAdd();
        resolver.AddMul();
        resolver.AddSub();
        resolver.AddFullyConnected();
        resolver.AddSoftmax();
        resolver.AddQuantize();
        resolver.AddDequantize();
        resolver.AddConv2D();
        resolver.AddDepthwiseConv2D();
        resolver.AddMaxPool2D();
        resolver.AddAveragePool2D();
        resolver.AddPack();
        resolver.AddUnpack();
        resolver.AddSplit();
        resolver.AddSplitV();
        resolver.AddSqueeze();
        
        // Create interpreter
        static tflite::MicroInterpreter* interpreter = new tflite::MicroInterpreter(
            model, resolver, tensor_arena, arena_size);
        
        // Allocate tensors
        TfLiteStatus allocate_status = interpreter->AllocateTensors();
        if (allocate_status != kTfLiteOk) {
            MicroPrintf("AllocateTensors() failed");
            return nullptr;
        }
        
        MicroPrintf("Model loaded successfully!");
        MicroPrintf("Number of inputs: %d", interpreter->inputs_size());
        MicroPrintf("Number of outputs: %d", interpreter->outputs_size());
        
        // Print input tensor info
        for (int i = 0; i < interpreter->inputs_size(); i++) {
            TfLiteTensor* input = interpreter->input(i);
            MicroPrintf("Input %d: shape [", i);
            for (int j = 0; j < input->dims->size; j++) {
                MicroPrintf("%d", input->dims->data[j]);
                if (j < input->dims->size - 1) MicroPrintf(", ");
            }
            MicroPrintf("]");
        }
        
        // Print output tensor info
        for (int i = 0; i < interpreter->outputs_size(); i++) {
            TfLiteTensor* output = interpreter->output(i);
            MicroPrintf("Output %d: shape [", i);
            for (int j = 0; j < output->dims->size; j++) {
                MicroPrintf("%d", output->dims->data[j]);
                if (j < output->dims->size - 1) MicroPrintf(", ");
            }
            MicroPrintf("]");
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