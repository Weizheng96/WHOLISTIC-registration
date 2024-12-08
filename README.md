# Welcome to WBI registration
**A fast, accurate, and non-rigid image registration method for Whole-Body cellular activity Imaging (WBI).**

## Introduction
WBI Registration is a cutting-edge method designed to correct non-rigid motion caused by skeletal and smooth muscle contractions. This enables precise cellular activity analysis and motion analysis for fluorescent data. The method utilizes patch-wise iterative modified optical flow with an image pyramid to achieve high flexibility and robustness.


Below are examples showcasing the results of WBI Registration:

-**Left**: Raw video

-**Right**: Motion-corrected video

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


## Advantage:
- **Accurate non-rigid registration**: Delivers precise motion correction.
- **Fast and parallelizable**: Optimized for GPU acceleration.
- **Flexible masking**: Allows users to ignore unwanted regions.
- **Robust to noise**: Performs well even with noisy fluorescent data.

## Suitable Data for WBI Registration
WBI Registration assumes that the template image and the moving image have similar intensities (or change gradually). Thus, At least one channel of your data should avoid fast-changing activities, such as Calcium activity signals, to ensure optimal results.

## Using the Code
See [```demo.m```](https://github.com/Weizheng96/WholeFishAnalyss/blob/main/demo.m) for a demo of the code. The algorithm is implemented in the function ```getMotionHZR_Wei_v2d2.m```. GPU acceleration is recommended for optimal performance.

| Parameter name | Description |
|----------------|-------------|
| ```dat_ref``` | template image |
| ```dat_mov``` | moving image |
| ```smoothPenalty``` | motion field smoothness penalty, large smooth penalty give smooth motion field |
| ```option.layer``` | number of downsampled pyramid layers, the downsampled layer can avoid local optimal |
| ```option.iter``` | max number of iteration of each layer |
| ```option.r``` | control patch size (large patch size gives more rigid but more reliable results) |
| ```option.mask_ref``` | mask of the template image, set the pixel to true to ignore the pixel |
| ```option.mask_mov``` | mask of the moving image, set the pixel to true to ignore the pixel |

Practical usage examples for WBI data are available in ['''examples directory'''](https://github.com/Weizheng96/WBI-registration/tree/main/examples).

## Requirements
- Matlab 2023a or later
- Matlab Image Processing Toolbox
- Matlab Parallel Computing Toolbox

## Citation
Details will be announced soon.
