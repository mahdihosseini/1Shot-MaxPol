function [down_sampled_image] = maxpol_downsample(scan_image, scale, h)

%%
if scale > 1
    warning('down-sampling scale should be less than one, returning the same input image')
    return
end
max_skip = 2;
if 1/scale > max_skip
    N = log(1/scale) / log(max_skip);
    N = round(N);
    skip = (1/scale)^(1/N);
else
    skip = 1/scale;
    N = 1;
end
if strcmp(class(scan_image), 'uint8')
    scan_image = single(scan_image);
end
down_sampled_image = scan_image;
for iteration = 1: N
    %%
    [m, n, q] = size(down_sampled_image);
    indx_i = round([1: skip: m]);
    indx_j = round([1: skip: n]);
    
    %%  lowpass filter
    down_sampled_image = imfilter(down_sampled_image, h(:), 'conv', 'symmetric');
    down_sampled_image = imfilter(down_sampled_image, h(:)', 'conv', 'symmetric');
    
    %%  down-sampling
    down_sampled_image = down_sampled_image(indx_i, indx_j, :);
    
    %%
    down_sampled_image(down_sampled_image>255) = 255;
    down_sampled_image(down_sampled_image<0) = 0;
end