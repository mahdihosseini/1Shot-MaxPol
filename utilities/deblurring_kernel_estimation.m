function [deblurring_kernel] = deblurring_kernel_estimation(h_psf, model_type)

%%
switch model_type
    case 'Gaussian'
        feasible_range = [0, 0.9];
        max_amplitude = 30;
    case 'Laplacian'
        feasible_range = [0, 1];
        max_amplitude = 30;
end
N = 16;

%%
l_deblurring = 32;
P_cutoff = 2*l_deblurring-0;
x_polyomomial = [-l_deblurring:l_deblurring];

%%
l = (size(h_psf,1)-1)/2;
x = [-l:l];

%%
for channel = 1: size(h_psf, 2)
    blurring_kernel = h_psf(:, channel)/sum(h_psf(:, channel));
    [alpha_estimated, kernel_spectrum(:, channel), ...
        omega, y_full, omega_selected, y_selected] = ...
        specrum_fit(blurring_kernel, N, max_amplitude);
    %%
    y_fit_even = 0;
    for n = 0: floor(N/2)
        y_fit_even = y_fit_even + ...
            (-1)^n*alpha_estimated(n+1)*omega.^(2*n);
    end
    y_fit = y_fit_even;
    
    %%
    clear d D
    d(1, :) = derivcent(l_deblurring, 2*l_deblurring, 0, 0, false);
    for n = 1: floor(N/2)
        d(n+1, :) = alpha_estimated(n+1)/alpha_estimated(1)*...
            derivcent(l_deblurring, P_cutoff, 0, 2*n, false);
    end
    D(:, channel) = sum(d, 1);
    deblurring_kernel(:, channel) = sum(d(2: end, :), 1);
end