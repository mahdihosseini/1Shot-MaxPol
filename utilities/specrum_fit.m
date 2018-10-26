function [alpha_estimated, kernel_spectrum, omega, y_full, omega_selected, y_selected] = ...
    specrum_fit(blurring_kernel, N, max_amplitude)

%%  parameter for frequency response (fft) calculation
n_fft = 1024;
stp = 2*pi/(n_fft);
omega = [-pi: stp: pi-stp];

%%
kernel_spectrum = fftshift(fft(blurring_kernel, n_fft));

%%
if false
    snr_level = 1e-3;
    y_full = conj(kernel_spectrum)./(abs(kernel_spectrum).^2 + snr_level);
else
    y_full = 1./kernel_spectrum;
end

%%  polynomial fitting on the frequency domain
% indx = zeros(1, n_fft);
% for iteration = 1: size(feasible_range, 1)
%     indx = or(indx, and(abs(omega) >= feasible_range(iteration, 1)*pi, abs(omega) <= feasible_range(iteration, 2)*pi));
% end
indx = abs(y_full) < max_amplitude;
omega_selected = omega(indx);
y_selected = y_full(indx);
if false
    figure
    plot(omega_selected, real(y_selected))
    hold on
    plot(omega_selected, imag(y_selected))
    plot(omega_selected, abs(y_selected)); axis tight
end
y_selected = abs(y_selected);
y_full = abs(y_full);

%%
fitting_type_even = [];
for n = 0: floor(N/2)
    polyTerms{n+1} = ['(-1)^', num2str(n), '*x^',num2str(2*n)];
    polyCoeffs{n+1} = ['a',num2str(2*n)];
end
ft = fittype(polyTerms, 'coefficients', polyCoeffs);
w = ones(size(omega_selected));
FO = fit(omega_selected(:), y_selected(:), ft, 'Weights', w); % 'Trust-Region'
for n = 0: floor(N/2)
    alpha_estimated(n+1) = eval(['FO.a',num2str(2*n)]);
end