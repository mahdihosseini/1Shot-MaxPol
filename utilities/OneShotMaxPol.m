function [deblurred_image] = OneShotMaxPol(image_scan_original, deblurring_kernel, model_type, alpha_estimate, c1_estimate, h_psf)

[N_1, N_2, N_3] = size(image_scan_original);
l = (numel(h_psf(:,1))-1)/2;
x_polynomial = [-l:l];
fitting_function = @(amp, alpha, beta, x) generalized_Gaussian_for_fitting(x, amp, alpha, beta);
for channel = 1: N_3
    switch model_type
        case 'Gaussian'
            beta = 1.8;
            sigm = alpha_estimate(channel)*0.85;
        case 'Laplacian'
            beta = 1;
            sigm = alpha_estimate(channel)*0.5;
    end
    %  apply denoising
    h_GGaussian = fitting_function(1, sigm, beta, x_polynomial);
    h_GGaussian = h_GGaussian/sum(h_GGaussian);
    image_scan_blurry_denoised = imfilter(image_scan_original(:,:,channel), h_GGaussian(:), 'symmetric', 'conv');
    image_scan_blurry_denoised = imfilter(image_scan_blurry_denoised, h_GGaussian(:)', 'symmetric', 'conv');
    
    %  apply deblurring kernel on image observation
    deblurring_edges_1 = imfilter(image_scan_blurry_denoised, deblurring_kernel(:, channel), 'symmetric', 'conv');
    deblurring_edges_2 = imfilter(image_scan_blurry_denoised, deblurring_kernel(:, channel)', 'symmetric', 'conv');
    deblurring_edges_12 = imfilter(deblurring_edges_1, deblurring_kernel(:, channel)', 'symmetric', 'conv');
    deblurring_edges = deblurring_edges_1 + deblurring_edges_2 + deblurring_edges_12;
    
    %
    gamma_significance(channel) = entropy(image_scan_blurry_denoised)/(entropy(deblurring_edges)+0.5)*0.5;
    deblurred_image(:,:,channel) = image_scan_original(:,:,channel) + gamma_significance(channel) * deblurring_edges;
end
%  convert double format into uint8 format
deblurred_image = im2uint8(deblurred_image);