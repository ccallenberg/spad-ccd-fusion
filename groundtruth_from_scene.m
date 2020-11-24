% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function gt = groundtruth_from_scene(scene, spatialResolution, tempDownFactor)

time_downscale_factor = tempDownFactor;

w = size(scene, 1);
h = size(scene, 2);
t = size(scene, 3);

w_sim = spatialResolution;
h_sim = spatialResolution;

% choose squared crop because SPAD sensor is square shaped anyway
if w ~= h
    if w > h
        scene = scene(ceil((w-h)/2):end-ceil((w-h)/2), :, :);
    else
        
        scene = scene(:, ceil((h-w)/2):end-ceil((h-w)/2), :);
    end
end


% downscale in spatial dimension

scenesd = zeros(w_sim, h_sim, t);


for i = 1:t
    scenesd(:,:,i) = imresize(squeeze(scene(:,:,i)), [w_sim, h_sim]);
end


% downscale in temporal dimension
if mod(t, time_downscale_factor) ~= 0
    disp('t is not a multiple of time_downscale_factor!');
else
    scened = zeros(w_sim, h_sim, t/time_downscale_factor);
    
    for k = 1:t/time_downscale_factor
        scened(:,:,k) = sum(scenesd(:,:,time_downscale_factor*(k-1)+1:time_downscale_factor*k), 3);
    end
    
end

gt = scened;

end

