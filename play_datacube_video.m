% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function play_datacube_video(data, scale)

if nargin == 1
    scale = 1;
end

normf = max(data(:));
figure;
for i = 1:size(data, 3)
    pause(0.2);
    ccd = sum(data, 3);
    subplot(1, 2, 1)
    figure(1); imshow(imresize(ccd, scale, 'nearest')/max(ccd(:)))
    title('Temporal sum');
    subplot(1, 2, 2)
    figure(1); imshow(imresize(squeeze( data(:,:,i)./normf) , scale, 'nearest'));
    title(sprintf('SPAD time bin %d', i));
    drawnow;
end