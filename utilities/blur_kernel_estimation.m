function [h_PSF, c1_estimate, c2_estimate, alpha_estimate, amplitude_estimate] = ...
    blur_kernel_estimation(image_scan_original, model_type, scale)

%%  image downsampling using MaxPol-LPF
[N_1, N_2, N_3] = size(image_scan_original);
pad_box = zeros(1, 2);
if mod(N_1, 2) == 0
    pad_box(1, 1) = 1;
end
if mod(N_2, 2) == 0
    pad_box(1, 2) = 1;
end
image_scan_padded = padarray(image_scan_original, pad_box, 'pre', 'symmetric');
load('maxpol_lpf.mat')
[image_scan_scaled] = maxpol_downsample(image_scan_padded, scale, h_dowsampling);

%% calculate the image spectrum of images of original and degraded models
n_bins = 13;
[spect_scan_original, r_grid_bin] = radSpec(image_scan_padded, n_bins);
[spect_scan_scaled, ~] = radSpec(image_scan_scaled, n_bins);

%%
switch model_type
    case 'Laplacian'
        A = @(s, alpha, x) 16*s^5/alpha^4./x.^5;
        B = @(s, alpha, x) (16*s^4 + 8*alpha^2*x.^2*s^2)/alpha^4./x.^4;
        R = @(amp, alpha, c1, c2, x) amp*((2*pi*A(1, alpha, x)./sqrt(B(1, alpha, x).^2 + 1)) + c1)./...
            ((2*pi*A(1/scale, alpha, x)./sqrt(B(1/scale, alpha, x).^2 + 1)) + c2);
        beta = 1;
    case 'Gaussian'
        R = @(amp, alpha, c1, c2, x) amp*(exp(-alpha^2*x.^2/2) + c1*x)./(1/scale*exp(-alpha^2*x.^2/2/(1/scale)^2) + c2*x);
        beta = 1.8;
end
fo = fitoptions('Method','NonlinearLeastSquares',...
    'Lower',[0, 0.75, 0, 0],...
    'Upper',[Inf, 6, 4, 4],...
    'StartPoint',[1 1 .05 .05]);
g = fittype(R,'coeff',{'amp', 'alpha', 'c1', 'c2'},'options',fo);

%%
l = 16; % define tap-length of FIR blurring kernel
for channel = 1: N_3
    a = spect_scan_original(:, channel);
    b = spect_scan_scaled(:, channel);
    h_estimate_fft(:, channel) = a./b;
    Omega = [r_grid_bin];
    FO = fit(Omega(:), h_estimate_fft(:, channel), g); % 'Trust-Region'
    
    amplitude_estimate(channel) = eval(['FO.amp']);
    alpha_estimate(channel) = eval(['FO.alpha']);
    c1_estimate(channel) = eval(['FO.c1']);
    c2_estimate(channel) = eval(['FO.c2']);
    h_PSF(:, channel) = generalized_Gaussian_for_fitting([-l:l], ...
        amplitude_estimate(channel), ...
        alpha_estimate(channel), ...
        beta);
end