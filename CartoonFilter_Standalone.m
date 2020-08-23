%% *Welcome to the Cartoon Filter!*
% This time we're going to create a filter to give a cartoonish effect to any 
% image we want, and how? With some basic Image Processing :D
% 
% The general process can be summarized into the following steps:
%% 
% # *Loading* the image
% # Defining and applying an *Anisotropic Diffusion filter*
% # k-Mean *Clustering* of the colors in the filtered image
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

im_small = imresize(im,[640 NaN],"AntiAliasing",true);
% im_small = im;
[m,n,n_colors] = size(im_small);
% imshow(im_small);
% title('Original image')
%% 
% We select the parameters for the Anisotropic Difussion

K = 20;
T = 50;
%% 
% And now apply it to |image *im_small*|

im_smooth = im_small;
for i = 1:n_colors   
    im_smooth(:,:,i) = imdiffusefilt(im_small(:,:,i),"GradientThreshold",K,"NumberOfIterations",T);
end
% imshow(im_smooth);
montage({im_small,im_smooth});
title(['Smoothing using Anisotropic Diffusion. \kappa = ' num2str(K) '. T = ' num2str(T)])
%% 
% With the smoothed image, it is time to cluster the colors in it to give it 
% a more basic color palette, as in a comic book. 
% 
% For that we choose whether we want to use clustering over RGB or HSV values 
% and the number of k-mean clusters

n_clusters = 2;
colorspace = "RGB";
%% 
% With the selection we adapt our image to the corresponde color space

if(colorspace=="HSV")    
    im_clustered = double(rgb2hsv(im_smooth));    
elseif(colorspace=="RGB")
    im_clustered = double(im_smooth); 
elseif(colorspace=="LAB")
    im_clustered = double(rgb2lab(im_smooth));
end
%% 
% And perform the color clustering in each channel of the image. For HSV, the 
% cluster number is kept high to maintain a good level of saturation

for i = 1:n_colors
    aux = im_clustered(:,:,i);
    if(colorspace=="HSV" && i==2)
        [idx3,C,~] = kmeans(aux(:),max(10,n_clusters),'Distance','cityblock');
%     elseif(colorspace=="LAB" && i==1)
%         [idx3,C,~] = kmeans(aux(:),n_clusters+1,'Distance','cityblock');
    else
        [idx3,C,~] = kmeans(aux(:),n_clusters,'Distance','cityblock');    
    end
    
    im_clustered(:,:,i) = reshape(C(idx3),m,[]);
end

if(colorspace=="HSV")    
    im_clustered = hsv2rgb(im_clustered);
elseif(colorspace=="RGB")
    im_clustered = uint8(im_clustered);
elseif(colorspace=="LAB")
    im_clustered = lab2rgb(im_clustered);
end
montage({im_small, im_clustered});
title(['Wait for it, its gonna be... ' newline '\color{magenta}LEGEND-\color{blue}DARY'],'FontName','Morpheus','Interpreter',"tex")
%% 
% For the last step we recover border data, to gave the final touch of the comic 
% artistic style

im_bw = im2bw(im_clustered);
BW_filled = imfill(im_bw,'holes');
boundaries = bwboundaries(BW_filled);
%% 
% And finally we plot everything together

figure('name','Final result',"WindowState","maximized") %
imshow(im_clustered); hold on;

for k=1:size(boundaries)
   b = boundaries{k};
   plot(b(:,2),b(:,1),'Color',[0.2 0.2 0.2],'LineWidth',1);
end
hold off;
% title(['Voila!' newline '\color{magenta}' char(colorspace) '\color{black} color space '...
%        'with \color{magenta}' num2str(n_clusters) '\color{black} clusters/color' ], "Interpreter","tex")

set(gca,'units','pixels')   % set the axes units to pixels
x = get(gca,'position')     % get the position of the axes
set(gcf,'units','pixels')   % set the figure units to pixels
y = get(gcf,'position')     % get the figure position
set(gcf,'position',[y(1) y(2) x(3) x(4)]) % set the position of the figure to the length and width of the axes
set(gca,'units','normalized','position',[0 0 1 1]) % set the axes units to pixels

F = getframe(gcf);
im_cartoon = F.cdata;
montage({im_small,im_cartoon});