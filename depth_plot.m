% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function lim = depth_plot(data, lim)

[w, h, t] = size(data);

map = sum(data, 3);
thr = 0.15; % might have to be adjusted depending on the dataset for nicer depth plots (cuts out noisy pixels)
map(map < thr*prctile(map(:), 97)) = 0;
map(map > 0) = 1;
map = repmat(map, [1 1 t]);
data_interp_depth = map .* data;

depth = zeros(w, h);

for i = 1:w
    for j = 1:h
        [val, depth(i, j)] = max(data_interp_depth(i, j, :));
    end
end
depth = depth-1;
depth = 299792458 * depth * 55e-12  / 2 *100; % calculate distance from time depth
depth_lin = depth(:);
depth_lin(depth_lin == 0) = [];
p = prctile(depth_lin, 2);
depth(depth < p) = p;
blackvalue = min(depth(:))-1;
depth(map(:,:,1)==0) = blackvalue;
figure; imagesc(depth);
set(gca,'dataAspectRatio',[1 1 1])
set(gcf,'Position',[100 100 900 900])
parula_masked = parula(1024);
parula_masked(1,:) = [0 0 0];

colormap(parula_masked);
cb = colorbar;
cb.FontSize = 20;
if (exist('lim'))
    caxis(lim);
end
set(gca,'xtick',[]);
set(gca,'ytick',[]);
ylabel(cb, 'distance / cm', 'FontSize', 28);

lim = caxis;