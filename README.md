# MATLAB-Cartoon Filter

This time we're going to create a filter to give a cartoonish effect to any image we want, and how? With some basic Image Processing :D

The general process can be summarized into the following steps:

1. Defining and applying an **Anisotropic Diffusion filter**
1. k-Mean **Clustering** of the colors in the filtered image
1. **Replacing the colors** in the filtered image with the new color mapping from the clusters
1. **Recovering borders** and adding them do the filtered image
1. Profit

Example of results:

