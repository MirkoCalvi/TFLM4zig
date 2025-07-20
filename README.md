
Int the create_tflm_tree.py it says:

"""  
Starting point for writing scripts to integrate TFLM with external IDEs.

This script can be used to output a tree containing only the sources and headers
needed to use TFLM for a specific configuration (e.g. target and
optimized_kernel_implementation). This should serve as a starting
point to integrate TFLM with external IDEs.

The goal is for this script to be an interface that is maintained by the TFLM
team and any additional scripting needed for integration with a particular IDE
should be written external to the TFLM repository and built to work on top of
the output tree generated with this script.

We will add more documentation for a desired end-to-end integration workflow as
we get further along in our prototyping. See this github issue for more details:
  https://github.com/tensorflow/tensorflow/issues/47413

"""
--  

I launched 

```
python3 ~/tflite-micro/tensorflow/lite/micro/tools/project_generation/create_tflm_tree.py   ~/Documents/zig/tflm4zig/tflm_tree  --examples=hello_world --rename_cc_to_cpp
```


