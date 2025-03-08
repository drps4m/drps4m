tStart = cputime;
img = imread('srpic.jpeg.jpg');  
if size(img, 3) == 3
    img_gray = rgb2gray(img);   
else
    img_gray = img; 
end
img_double = im2double(img_gray);
figure;
imshow(img_gray);
title('Original Image');
n = 1;              
wavelet_type = 'sym2';  
[c, l] = wavedec2(img_double, n, wavelet_type);

%threshold = wthrmngr('dw2dcompGBL','rem_n0',C,l); (add this line while
%compiling for bal_sn and rem_n0)
opt = 'gbl';       
threshold =0.4667;     
sorh = 'h';          
keepapp = 1;      
[xd, cxd, lxd, perf0, perfl2] = wdencmp(opt, c, l, wavelet_type, n, threshold, sorh, keepapp);
figure;
subplot(1, 2, 1);
imshow(img_gray);
title('Original Image');
subplot(1, 2, 2);
imshow(xd);
title(['Compressed Image - Global Threshold = ', num2str(threshold)]);
disp('Compression Score (% of coefficients retained):');
disp(perf0);  
disp('L2 Norm Recovery (% of L2 norm retained):');
disp(perfl2);
mse = mean((img_double(:) - xd(:)).^2);
psnr_value = 10 * log10(1 / mse);      
C = mat2gray(xd);
ref = mat2gray(img_gray);
[peaksnr, snr] = psnr(C, ref);
disp('SNR:');disp(snr)
disp('PSNR:');
disp(peaksnr)
tEnd = cputime - tStart;
disp(tEnd)
