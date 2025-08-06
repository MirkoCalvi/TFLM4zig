
// WRAPPER FOR mob_net 

#include "tensorflow/lite/micro/micro_interpreter.h"
#include "tensorflow/lite/micro/micro_mutable_op_resolver.h"
#include "tensorflow/lite/micro/system_setup.h"
#include "tensorflow/lite/schema/schema_generated.h"
#include "tensorflow/lite/micro/kernels/micro_ops.h"


// Include signal processing ops
#include "signal/micro/kernels/delay_flexbuffers_generated_data.h"
#include "signal/micro/kernels/energy_flexbuffers_generated_data.h"
#include "signal/micro/kernels/fft_auto_scale_kernel.h"
#include "signal/micro/kernels/fft_flexbuffers_generated_data.h"
#include "signal/micro/kernels/filter_bank_flexbuffers_generated_data.h"
#include "signal/micro/kernels/filter_bank_log_flexbuffers_generated_data.h"
#include "signal/micro/kernels/filter_bank_spectral_subtraction_flexbuffers_generated_data.h"
#include "signal/micro/kernels/filter_bank_square_root.h"
#include "signal/micro/kernels/framer_flexbuffers_generated_data.h"
#include "signal/micro/kernels/irfft.h"
#include "signal/micro/kernels/overlap_add_flexbuffers_generated_data.h"
#include "signal/micro/kernels/pcan_flexbuffers_generated_data.h"
#include "signal/micro/kernels/rfft.h"
#include "signal/micro/kernels/stacker_flexbuffers_generated_data.h"
#include "signal/micro/kernels/window_flexbuffers_generated_data.h"


// Include signal src processing ops
#include "signal/src/window.h"
#include "signal/src/energy.h"
#include "signal/src/fft_auto_scale.h"
#include "signal/src/rfft.h"
#include "signal/src/filter_bank.h"
#include "signal/src/filter_bank_square_root.h"
#include "signal/src/filter_bank_spectral_subtraction.h"
#include "signal/src/filter_bank_log.h"
#include "signal/src/pcan_argc_fixed.h"


// Globals to hold interpreter state
namespace {
    constexpr int kTensorArenaSize = 20 * 1024;
    const tflite::Model* model = nullptr;
    tflite::MicroInterpreter* interpreter = nullptr;
    tflite::MicroMutableOpResolver<9>* op_resolver = nullptr;
}

// Debugging custom op registration with correct type
const TFLMRegistration* Register_CUSTOM_OP(const char* custom_name) {
    static TFLMRegistration r = { nullptr, nullptr, nullptr, nullptr };
    printf("Warning: Custom op '%s' not implemented yet\n", custom_name);
    return &r;
}

extern "C" {
    void tflm_init() {
        tflite::InitializeTarget();
    }

    void* tflm_create_interpreter_from_model(uint8_t* arena_buf, size_t arena_size, const uint8_t* model_data) {
        model = tflite::GetModel(model_data);
        if (model->version() != TFLITE_SCHEMA_VERSION) {
            printf("Model version mismatch: expected %d, got %d\n", TFLITE_SCHEMA_VERSION, model->version());
            return nullptr;
        }

        printf("Creating op resolver...\n");
        op_resolver = new tflite::MicroMutableOpResolver<9>();

        printf("Registering common NN operators...\n");
        // ADD
        op_resolver->AddAdd();
        // CONV_2D
        op_resolver->AddConv2D();
        // DEPTHWISE_CONV_2D
        op_resolver->AddDepthwiseConv2D();
        // MUL
        op_resolver->AddMul();
        // PAD
        op_resolver->AddPad();
        // SOFTMAX
        op_resolver->AddSoftmax();
        // SUB
        op_resolver->AddSub();
        // TRANSPOSE
        op_resolver->AddTranspose();

        const auto* opcodes = model->operator_codes();
        if (opcodes) {
            printf("Model contains %d operator codes:\n", opcodes->size());
            for (size_t i = 0; i < opcodes->size(); ++i) {
                const auto* opcode = opcodes->Get(i);
                const int builtin_code = opcode->builtin_code();
                const char* custom_code = opcode->custom_code() ? opcode->custom_code()->c_str() : "null";
                printf("Op #%zu: builtin_code=%d, custom_code=%s\n", i, builtin_code, custom_code);
                if (builtin_code == tflite::BuiltinOperator_CUSTOM) {
                    printf(" !!! Warning: Custom op '%s' will be stubbed\n", custom_code);
                }
            }
        }

        printf("Creating interpreter...\n");
        interpreter = new tflite::MicroInterpreter(model, *op_resolver, arena_buf, arena_size);

        printf("Allocating tensors...\n");
        TfLiteStatus allocate_status = interpreter->AllocateTensors();
        if (allocate_status != kTfLiteOk) {
            printf("AllocateTensors failed with status: %d\n", allocate_status);
            return nullptr;
        }

        printf("Interpreter created successfully\n");
        return interpreter;
    }

    float* tflm_get_input_buffer(void* handle, int input_index) {
        auto* interpreter = static_cast<tflite::MicroInterpreter*>(handle);
        return interpreter->input(input_index)->data.f;
    }

    float* tflm_get_output_buffer(void* handle, int output_index) {
        auto* interpreter = static_cast<tflite::MicroInterpreter*>(handle);
        return interpreter->output(output_index)->data.f;
    }

    int tflm_invoke(void* handle) {
        auto* interpreter = static_cast<tflite::MicroInterpreter*>(handle);
        TfLiteStatus invoke_status = interpreter->Invoke();
        return (invoke_status == kTfLiteOk) ? 0 : -1;
    }

    int tflm_get_input_size(void* handle, int input_index) {
        auto* interpreter = static_cast<tflite::MicroInterpreter*>(handle);
        TfLiteTensor* input = interpreter->input(input_index);
        int size = 1;
        for (int i = 0; i < input->dims->size; i++) {
            size *= input->dims->data[i];
        }
        return size;
    }

    int tflm_get_output_size(void* handle, int output_index) {
        auto* interpreter = static_cast<tflite::MicroInterpreter*>(handle);
        TfLiteTensor* output = interpreter->output(output_index);
        int size = 1;
        for (int i = 0; i < output->dims->size; i++) {
            size *= output->dims->data[i];
        }
        return size;
    }
}