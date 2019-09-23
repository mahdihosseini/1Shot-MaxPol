# 1Shot-MaxPol
## A MATLAB Package for Natural Image Deconvolution

----------------------------------------------------------------
### General purpose
You can use this source code to deconvolve naturally blurred images

### Demo Example
--- Raw Image -------- Deblurred ---  
![RGB_Hyperspectral_raw_image_23](https://user-images.githubusercontent.com/7947948/61488237-b685ca80-a975-11e9-8ad5-1c3e7248b625.png) ![RGB_Hyperspectral_deblurred_image_23_maxpol](https://user-images.githubusercontent.com/7947948/61488248-bede0580-a975-11e9-8a0f-4926a2d490e4.png)

----------------------------------------------------------------
### Requirements
- MATLAB R2015b (minimum)
- [MaxPol package](https://github.com/mahdihosseini/MaxPol) should be installed

----------------------------------------------------------------
### MATLAB Codes

Demo function:  
-	demo_image_deblurring.m

Utility functions:  
-	maxpol_downsample.m
-	spectrum_calculation_circular.m
-	blur_kernel_estimation.m
-	generalized_Gaussian_for_fitting.m
-	specrum_fit.m
-	deblurring_kernel_estimation.m
-	OneShotMaxPol.m

----------------------------------------------------------------  
### Published Paper
*Mahdi S. Hosseini and Konstantinos N. Plataniotis "[Convolutional Deblurring for Natural Imaging](https://ieeexplore.ieee.org/abstract/document/8782833)," IEEE Transactions on Image Processing, 2019.* 

You can also read the paper from the [arXiv link](https://arxiv.org/abs/1810.10725)

----------------------------------------------------------------
### Author  
Mahdi S. Hosseini  
Email: mahdi.hosseini@mail.utoronto.ca  
http://www.dsp.utoronto.ca/~mhosseini/  

----------------------------------------------------------------
### Citation  
@article{hosseini2018convolutional,  
  title={Convolutional Deblurring for Natural Imaging},  
  author={Hosseini, Mahdi S and Plataniotis, Konstantinos N},  
  journal={IEEE Transactions on Image Processing},  
  year={2019}  
}
