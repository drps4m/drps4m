tic
img = imread('srpic.jpeg.jpg');  
if size(img, 3) == 3
    img_gray = rgb2gray(img);   
else
    img_gray = img; 
end
img_double = im2double(img_gray);
f = img_double;
g=imnoise(f,'poisson');
npic=g;
[C,S]=wavedec2(npic,1,'haar');
var=length(C)-S(size(S,1)-1,1)^2+1;
sigmahat=median(abs(C(var:length(C))))/0.6745;
thr = sigmahat*sqrt(2*log(474*474));
disp(thr);
tEnd = cputime - tStart;
toc