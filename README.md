# Welcome to WHOLISTIC-registration
**A fast, accurate, and non-rigid image registration method for Whole-Body cellular activity Imaging.**

---

## Introduction
WBI Registration is a cutting-edge method designed to correct non-rigid motion caused by skeletal and smooth muscle contractions. This enables precise cellular activity analysis and motion analysis for fluorescent data. The method utilizes patch-wise iterative modified optical flow with an image pyramid to achieve high flexibility and robustness.

Below are examples showcasing the results of WBI Registration:

-**Input (Left)**: Raw video

-**Output (Right)**: Motion-corrected video

<p align="center">
  <b>
    Example #1
  </b>
</p>

https://github.com/user-attachments/assets/871dfb15-49a5-47de-8b18-878880605e74

<p align="center">
  <b>
    Example #2
  </b>
</p>


https://github.com/user-attachments/assets/5fb45eca-02a1-4226-8208-2f6dbd6171a3

### Advantage
- **Accurate non-rigid registration**: Delivers precise motion correction.
- **Fast and parallelizable**: Optimized for GPU acceleration.
- **Flexible masking**: Allows users to ignore unwanted regions.
- **Robust to noise**: Performs well even with noisy fluorescent data.

### Suitable Data for WBI Registration
WBI Registration assumes that the template image and the moving image have similar intensities (or change gradually). Thus, At least one channel of your data should avoid fast-changing activities, such as Calcium activity signals, to ensure optimal results.

## Requirements
### OS Requirements
This package is supported for *Linux* and *Windows*. The package has been tested on the following systems:
+ Linux: Ubuntu 24.04
+ Windows: 22H2

### Software Requirements
- Matlab 2023a or later
- Matlab Image Processing Toolbox
- Matlab Parallel Computing Toolbox

### Hardware Requirements
- A discrete GPU with sufficient memory is recommended for acceleration.

## Installation and Using code

### Installation Instructions
Install required MATLAB and clone the repository. It takes approximately 20 minutes on a standard system.
   
### Demo

See [```demo.m```](https://github.com/Weizheng96/WholeFishAnalyss/blob/main/demo.m) for a demonstration of how to use the code.

Download the data file ```221124_f338_ubi_gCaMP7f_bactin_mCherry_CAAX_7dpf002.nd2``` to your machine and change the ```filePath``` in ```demo.m``` to the saved file.

This demo registers a frame with 1708×2304×13 pixel to the template, and provided the motion field and visulization of motion corrected frames. For a computer with NVIDIA RTX A4000, with the default parameters, it takes 12.8 sec to finish the registration.

### Key parameters
   
The main algorithm is implemented in the function ```getMotionHZR_Wei_v2d2.m```. The parameters in shown as below.
| Parameter name | Description |
|----------------|-------------|
| ```dat_ref``` | Template image. |
| ```dat_mov``` | Moving image. |
| ```smoothPenalty``` | Smoothness penalty for the motion field. Higher values produce smoother motion fields. |
| ```option.layer``` | Number of downsampled pyramid layers. More layers help avoid local optima. |
| ```option.iter``` | Maximum number of iterations per layer. |
| ```option.r``` | 	Patch size control. Larger patch sizes yield more rigid but reliable results. |
| ```option.mask_ref``` | Mask for the template image. Pixels set to ```true``` are ignored during registration. |
| ```option.mask_mov``` | Mask for the moving image. Pixels set to ```true``` are ignored during registration. |

### WHOLISTIC Real data example
Practical usage examples for WBI data are available in [```examples directory```](https://github.com/Weizheng96/WBI-registration/tree/main/examples).



## Citation
Details will be announced soon.
