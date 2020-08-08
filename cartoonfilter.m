function [im_small,im_clustered,im_cartoon] = cartoonfilter(im, K, T, n_clusters, colorspace, make_smaller)
%% CARTOONFILTER *Cartoon Filter Function!*
% This time we're going to create a filter to give a cartoonish effect to any 
% image we want, and how? With some basic Image Processing :D
% 
% The general process can be summarized into the following steps:
%% 
% # Defining and applying an *Anisotropic Diffusion filter*
% # k-Mean *Clustering* of the colors in the filtered image
% # *Replacing the colors* in the filtered image with the new color mapping 
% from the clusters
% # *Recovering borders* and adding them do the filtered image
% # Profit
%% 
% Now we resize for simplicity and faster execution times _*(to be removed in 
% final version)*_
im_small = im;
if(make_smaller)
    im_small = imresize(im,[640 NaN],"AntiAliasing",true);
end
[m,~,n_colors] = size(im_small);
%% 
% We apply the Anisotropic Difussion to |image *im_small*|
im_smooth = im_small;
for i = 1:n_colors
    im_smooth(:,:,i) = imdiffusefilt(im_small(:,:,i),"GradientThreshold",K,"NumberOfIterations",T);
end
%% 
% With the smoothed image, it is time to cluster the colors in it to give it 
% a more basic color palette, as in a comic book. 
% 
% With the selection of the *number of clusters* and *colorspace* we adapt our 
% image to the corresponde color space
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
%% 
% For the last step we recover border data, to give the final touch of the cartoon 
% artistic style
im_bw = im2bw(im_clustered);
BW_filled = imfill(im_bw,'holes');
boundaries = bwboundaries(BW_filled);
%% 
% And finally we plot everything together a retrieve the frame to an image
figure('Visible',"off")
imshow(im_clustered); hold on;
for k=1:size(boundaries)
    b = boundaries{k};
    plot(b(:,2),b(:,1),'Color',[0.2 0.2 0.2],'LineWidth',1);
end
hold off;
F = getframe(gcf);
[im_cartoon, ~] = frame2im(F);
close(gcf)
end