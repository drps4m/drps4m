tic
I = imread('srpic.jpeg.jpg');
[counts,x] = imhist(I,16);
stem(x,counts)
T = otsuthresh(counts);
disp(T);
toc