% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function [SPADdata, ccd_img] = create_sim_measurement(groundtruth, spatialResolution, ccdResolution, sigmaBlur, addnoise)

w = size(groundtruth, 1);
h = size(groundtruth, 2);
t = size(groundtruth, 3);
disp('Building simulated measurement...');

A_3d = build_A3d(w, h, t, spatialResolution, sigmaBlur);


scene_sparse = sparse(double(reshape(groundtruth, [w*h*t, 1])));
    
    meas3d = A_3d*scene_sparse;
    
    ccd_img = double(squeeze(sum(groundtruth, 3)));
    ccd_img = imresize(ccd_img, [ccdResolution, ccdResolution], 'nearest');
    
    if addnoise
        
        % parameters for Gaussian noise:
        noise_sigma = 6.1;
        noise_mean = 5.6;

        noise = randn(size(meas3d));
        noise = noise*noise_sigma + noise_mean;
        meas3dnoise = meas3d + noise;
        meas3dnoise = meas3dnoise + imnoise(meas3dnoise, 'poisson'); % add Gauss and Poisson noise to measurement
        meas3d = meas3dnoise;
    
    end
    
    SPADdata = reshape(full(meas3d), [spatialResolution, spatialResolution, t]);
    disp('Done.')
end