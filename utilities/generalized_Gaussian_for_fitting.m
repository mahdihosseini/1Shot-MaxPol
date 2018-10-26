function [h_GG] = generalized_Gaussian_for_fitting(x, amp, sgm, beta)

A = sgm * sqrt(gamma(1/beta) / gamma(3/beta));
h_GG = amp/(2*gamma(1+1/beta)*A)*exp(-abs((x)/A).^beta);