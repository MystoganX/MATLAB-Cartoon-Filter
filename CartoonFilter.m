%% *Welcome to the Cartoon Filter!*
% This time we're going to create a filter to give a cartoonish effect to any 
% image we want, and how? With some basic Image Processing :D
% 
% The general process can be summarized into the following steps:
%% 
% # *Loading* the image
% # Defining and a applying an *Anisotropic Diffusion filter*
% # Mean Shift *Clustering* of the colors in the filtered image
% # *Replacing the colors* in the filtered image with the new color mapping 
% from the clusters
% # *Recovering borders* and adding them do the filtered image
% # Profit
%% 
% First of all, our always appreciated clearing of variables and loading the 
% image

clear variables; clc; close all;
file = uigetimagefile;
im = imread(file);
%% 
% Now we resize for simplicity and faster execution times _*(to be removed in 
% final version)*_

A = imresize(im,[640 NaN],"AntiAliasing",true);
[m,n,~] = size(A);
imshow(A);
%% 
% We select the parameters for the Anisotropic Difussion

K = 15;
N = 30;
%% 
% And now apply it to |image *A*|

C = A;
for i = 1:size(A,3)   
    C(:,:,i) = imdiffusefilt(A(:,:,i),"GradientThreshold",K,"NumberOfIterations",N);
end
imshow(C);
% montage({A,B});
title(['Smoothing using Anisotropic Diffusion. \kappa = ' num2str(K) '. N = ' num2str(N)])
%% 
% *Alternative version* with my own implementation of the |Anisotropic Diffusion|

lambda = 0.25;
B = anisotropicDiffusion(A,lambda,K,T);
imshow(B/255);