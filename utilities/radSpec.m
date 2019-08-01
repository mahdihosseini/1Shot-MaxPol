function [spec, r_grid_bin] = radSpec(inputImage, n_bins)

%RADSPEC radial spectrum
%
%   [radSpec] = radSpec(im, n_bins)
%
%   Returns amplitude spectrum of image in frequency domain using circular
%   bounds for calculation
%
%   Input(s):
%   'im'        input image N1xN2xN3
%   'n_bins'    number of bins for histogram calculation
%
%   Output(s):
%   'radSpec'	spectrum response
%
%   See also DEBLURRING_KERNEL_ESTIMATION
%
%
%   Copyright (c) 2019 Mahdi S. Hosseini
%
%   University of Toronto
%   The Edward S. Rogers Sr. Department of,
%   Electrical and Computer Engineering (ECE)
%   Toronto, ON, M5S3G4, Canada
%   Tel: +1 (416) 978 6845
%   email: mahdi.hosseini@mail.utoronto.ca

[N_1, N_2, ~] = size(inputImage);
if mod(N_1, 2) == 0
    inputImage = padarray(inputImage, [1, 0], 'pre');
end
if mod(N_2, 2) == 0
    inputImage = padarray(inputImage, [0, 1], 'pre');
end
[N_1, N_2, N_3] = size(inputImage);
r_max = floor(max([N_1, N_2])/2);

for channel = 1: N_3
    I = inputImage(:,:,channel);
    FT = fftshift(fft2(I, 2*r_max+1, 2*r_max+1));
    frequency_spectrum = abs(FT);
    if false
        frequency_spectrum(:, floor(N_2/2)+1) = 0;
        frequency_spectrum(floor(N_1/2)+1, :) = 0;
    end
    h_bin = 1/n_bins;
    r_grid_bin = [h_bin:h_bin:1]'*pi;
    r_grid = [-r_max: r_max]/r_max*pi;
    [X, Y] = meshgrid(r_grid);
    Y = -Y;
    A = sqrt(X.^2 + Y.^2);    
    circle_mask = A <= pi;
    pixel_area = pi^3/sum(circle_mask(:));
    for iteration = 1: n_bins
        mask_out =  A <= r_grid_bin(iteration);
        if iteration ~= 1
            mask_in = A <= r_grid_bin(iteration-1);
            mask = xor(mask_out, mask_in);
        else
            mask = mask_out;
        end
        S(iteration) = pixel_area * sum(mask(:));
        spec(iteration, channel) = ...
            sum(frequency_spectrum(mask))/S(iteration);
    end
    spec(:, channel) = spec(:, channel)/spec(1, channel);
end