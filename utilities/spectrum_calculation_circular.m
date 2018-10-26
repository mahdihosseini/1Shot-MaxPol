function [radial_spectrum, r_grid_bin] = spectrum_calculation_circular(im, n_bins)

[N_1, N_2, ~] = size(im);
if mod(N_1, 2) == 0
    im = padarray(im, [1, 0], 'pre');
end
if mod(N_2, 2) == 0
    im = padarray(im, [0, 1], 'pre');
end
[N_1, N_2, N_3] = size(im);
r_max = floor(max([N_1, N_2])/2);

for channel = 1: N_3
    I = im(:,:,channel);
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
        radial_spectrum(iteration, channel) = ...
            sum(frequency_spectrum(mask))/S(iteration);
    end
    radial_spectrum(:, channel) = radial_spectrum(:, channel)/radial_spectrum(1, channel);
end