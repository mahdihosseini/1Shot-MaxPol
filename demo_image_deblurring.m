clear all
close all
clc

%%
addpath([pwd, filesep, 'utilities'])
addpath([pwd, filesep, 'raw images'])

%%
do_export = false; % export restored images
scale = 1/4;    % define the down-sampling scale (default is 1/4)
model_type = 'Gaussian';   % PSF model: 'Gaussian' or 'Laplacian'

%%
image_name = 'image_4.tif';
image_scan_original = imread(image_name);
image_scan_original = im2double(image_scan_original);
[N_1, N_2, N_3] = size(image_scan_original);

%%
[h_psf, c1_estimate, c2_estimate, alpha_estimate, amplitude_estimate] = ...
    blur_kernel_estimation(image_scan_original, model_type, scale);

%%
[deblurring_kernel] = deblurring_kernel_estimation(h_psf, model_type);

%%
significany = 0.5; % edge significany control (optional) default is 0.5
[deblurred_image] = OneShotMaxPol(image_scan_original, deblurring_kernel, ...
    model_type, alpha_estimate, c1_estimate, h_psf, significany);

%%
figure('rend','painters','pos', [50 , 300, 1500, 600]);
subplot(1,2,1)
imshow(image_scan_original)
title('Natural Blurred Image')
subplot(1,2,2)
imshow(deblurred_image)
title('1Shot-MaxPol Deblurring')

%%
if do_export
    imwrite(deblurred_image, [pwd, filesep, 'restored images', filesep, ...
        model_type, '_', image_name], 'TIFF', 'compression', 'none')
end