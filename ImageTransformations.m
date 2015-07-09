% c. Translation and Rotation

% Translation of an Image
clc;
clear all;
close all;
A=imread('E:\TUM\Courses\Summer Semester 2015\Machine Learning in Medical Imaging\Project\Extremely Randomized Trees\Dataset\Training\T1_01.TIFF');
display('Translation:');
s=size(A);
B=zeros(s(1)*2,s(2)*2);
B=uint8(B);
C=zeros(s(1)*2,s(2)*2);
C=uint8(C);
for x=1:s(1)
    for y=1:s(2)
        C(x,y)=A(x,y);
    end
end
a=input('Enter the x co-ordinate to which the image is to be translated: ');
b=input('Enter the y co-ordinate to which the image is to be translated: ');
for x=1:s(1)
    for y=1:s(2)
        B(x+a,y+b)=A(x,y);
    end
end
figure,imshow(C)
title('Original Image');
figure,imshow(B)
title('Translated Image');

% Rotation of an Image

im1 = imread('E:\TUM\Courses\Summer Semester 2015\Machine Learning in Medical Imaging\Project\Extremely Randomized Trees\Dataset\Training\T1_01.TIFF');
[m,n]=size(im1);
display('Rotation:');
theta_degree=input('Enter angle in degrees: ');
theta_radian = (theta_degree*pi)/180;
mdiag = m*sqrt(2);
ndiag = n*sqrt(2);
for t=1:mdiag
   for s=1:ndiag
      i = uint16((t-mdiag/2)*cos(theta_radian)+(s-ndiag/2)*sin(theta_radian)+m/2);
      j = uint16(-(t-mdiag/2)*sin(theta_radian)+(s-ndiag/2)*cos(theta_radian)+n/2);
      if i>0 && j>0 && i<=m && j<=n           
         im2(t,s)=im1(i,j);
      end
   end
end
figure,imshow(im1);

figure,imshow(im2)
title('Rotated Image');
