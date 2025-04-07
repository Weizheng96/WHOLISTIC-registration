# Welcome to WHOLISTIC-registration
**A fast, accurate, and non-rigid image registration method for Whole-Body cellular activity Imaging.**


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

## Installation and Demo

### Installation Instructions
Install required MATLAB and clone the repository. It takes approximately 20 minutes on a standard system.
   
### Demo

See [```demo.m```](https://github.com/Weizheng96/WholeFishAnalyss/blob/main/demo.m) for a demonstration of how to use the code. Change the ```dataPath``` in ```demo.m``` to the saved [```data folder```](https://github.com/Weizheng96/WHOLISTIC-registration/tree/main/data) and click "Run".

This demo registers a frame with 1708×2304×13 pixel to the template, and its output includes the estimated motion field and visulization of motion corrected frames. For a computer with NVIDIA RTX A4000, with the default parameters, it takes 12.8 sec to finish the registration.

### Key parameters
   
The main algorithm is implemented in the function ```getMotionHZR_Wei_v2d2.m```. The parameters is shown below.
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

## Usage instructions and Result reproduction 
To run WHOLISTIC-registration on our data and reproduce the results, check the code in [```examples directory```](https://github.com/Weizheng96/WBI-registration/tree/main/examples). The additional parameters for preprocessing are shown below.
| Parameter name | Description |
|----------------|-------------|
| ```frameJump``` | Set to ```1``` to process all frames, or set to the expected interval of frames to be processed. . |
| ```refLength``` | Number of frames used to generate floating template.|
| ```refJump``` | Skip frames when selecting frames for floating template.|
| ```initialLength``` | Number of frames used to initialize motion field.|
| ```maskRange``` | Moving immune cell size range, bright connected components within the size will be masked out.|


## Citation
Details will be announced soon.
