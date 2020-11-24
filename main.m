%% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn
% 11/2020

% The following code assumes cvx for Matlab and Gurobi to be installed
% (default cvx solvers can be used but are probably slower than Gurobi).
% Set all parameters as desired. All datasets shown in the paper are
% provided and can be loaded from this script (see below). 

% This script should be executed block by block (press ctrl+enter when block
% is highlighted). Optional blocks can be skipped.


%% set up cvx

cvx_setup
cvx_solver Gurobi_2

%% parameters to be set by user

% optimization coefficients (see Eq. 3 in main paper)
alpha = 1;
beta = 1e-3;
gamma = 1e-7;
delta = 1e-5;

sigmaBlur = 6;      % assumed blur in units of target pixel widths


usePaperParameters = true; % override user's parameters with parameters used to produce paper results

% SPAD and target resolution for upsampled LiF image (spatial):
highRes = 64; % target resolution
lowRes = 32; % only necessary when creating own simulated dataset from high res data

% subdirectory for results to be stored in
subd = './reconstructions/';

% please also choose a dataset in option 1 or option 2 below

%% (Option 1:) load real measurement data (choose this or option 2)

% real data set
path = '.';
% (uncomment one dataset from the list below)
% datasetname = 'steps';
% datasetname = 'letters';
% datasetname = 'waterglass';
datasetname = 'golfball';
% datasetname = 'basketball';

highRes = 96; % target resolution of our measurements
lowRes = 32; % resolution of our SPAD

% parameters used in the paper 
if usePaperParameters
    alpha = 1;
    beta = 1e-4;
    gamma = 1e-2;
    delta = 0;
    sigmaBlur = 6;
end

[SPADdata, ccd_img] = load_real_data(path, datasetname);

%% (Option 2:) alternatively: create simulated measurement from synthetic scene (choose this or option 1)

% (choose one of the following datasets by uncommenting)
datasetname = 'monkey';
% datasetname = 'table';

load([path '\synthetic_scenes\' datasetname '.mat']);

% parameters used in the paper 
if usePaperParameters
    switch datasetname
        case 'monkey'
            alpha = 1;
            beta = 1e-7;
            gamma = 1e-4;
            delta = 0;
            sigmaBlur = highRes/lowRes;
        case 'table'
            alpha = 1;
            beta = 1e-7;
            gamma = 1e-4;
            delta = 1e-7;
            sigmaBlur = 6*(highRes/256);
    end
end

[SPADdata, ccd_img] = create_sim_measurement(scene, lowRes, highRes, sigmaBlur, false);


%% (optional) view measurement data cube
play_datacube_video(SPADdata, 10);

%% reconstruct high resolution data

coeffs = [alpha, beta, gamma, delta];

tic;
reco = reconstruct_hres_lifimage(SPADdata, ccd_img, coeffs, highRes, sigmaBlur);
duration = toc;

% save reconstruction result in specific subdirectory
while exist(subd, 'dir')
    fprintf('Subdirectory >%s< already exists! You might overwrite files. \n', subd);
    reply = input('Do you still want to keep it this way? (y/n) ', 's');
    if  ~(strcmp(reply, 'y') || strcmp(reply, 'Y'))
        subd = input('Please enter a new subdirectory path:  ', 's');
        subd = [subd '/'];
    else
        break;
    end
end
mkdir(subd);
save(sprintf('%sreco_alpha%g_beta%g_gamma%g_delta%g_sigma%g.mat', subd, alpha, beta, gamma, delta, sigmaBlur), 'reco'); % save reconstructed datacube

% write info about reconstriction to file 
file = fopen(sprintf('%sinfo_reco_alpha%g_beta%g_gamma%g_delta%g_sigma%g.txt', subd, alpha, beta, gamma, delta, sigmaBlur), 'w');
fprintf(file, 'dataset: %s\n', datasetname);
fprintf(file, 'low resolution = %d\n', lowRes);
fprintf(file, 'target resolution = %d\n', highRes); 
fprintf(file, 'alpha = %d\n', alpha);
fprintf(file, 'beta = %d\n', beta);
fprintf(file, 'gamma = %d\n', gamma);
fprintf(file, 'delta = %d\n', delta);
fprintf(file, 'duration: %f\n', duration);
fprintf(file, 'blur sigma: %d\n', sigmaBlur);
fclose(file);

disp('Reconstruction finished, result saved.');

%% (optional) visualize results

play_datacube_video(reco, 1);

%% (optional) create further plots and images and also save in subdirectory

create_reco_images(reco, subd, coeffs, sigmaBlur, SPADdata, ccd_img);
