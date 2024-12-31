# Image_Segmentation_using_Bayesian_Statistics
An algorithm based on the Bayesian Decision Rule to distinguish between the foreground and background of an image.

The goal of this problem is to segment the “cheetah” image into its two components, cheetah (foreground) and grass (background).
We need to decide on an observation space to formulate this as a pattern recognition problem.
Here we will be using the space of 8 × 8 image blocks, i.e. we view each image as a collection of 8 × 8 blocks.
For each block, we compute the discrete cosine transform (function dct2 on MATLAB) and obtain an array of 8 × 8 frequency coefficients. We do this because the cheetah and the grass have different textures, with varying decompositions of frequency and the two classes should be better separated in the frequency domain. We then convert each 8 × 8 array into a 64-dimensional vector because it is easier
to work with vectors than with arrays.
The file Zig-Zag Pattern.txt contains the position (in the 1D vector) of each coefficient in the 8 × 8 array. The file TrainingSamplesDCT 8.mat contains a training set of vectors obtained from a similar image (stored as a matrix, each row is a training vector) for each of the classes. There are two matrices, TrainsampleDCT BG and TrainsampleDCT FG for foreground and background samples respectively.
To make estimating the class conditional densities easier, we are going to reduce each vector to a scalar. For each vector, we compute the index (position within the vector) of the coefficient with the second-largest energy value (absolute value). This is our observation or feature X.
By building a histogram of these indexes we obtain the class-conditionals for the two classes PX|Y (x|cheetah) and PX|Y (x|grass). The priors PY (cheetah) and PY (grass) should also be estimated from the training set.



<img width="266" alt="Screenshot 2024-12-31 at 10 49 59 AM" src="https://github.com/user-attachments/assets/024e5c22-06d6-4461-b666-8e4f40ef1825" />



