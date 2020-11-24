% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function create_reco_images(reco, subd, coeffs, sigmaBlur, SPADdata, ccd_img)


alpha = coeffs(1);
beta  = coeffs(2);
gamma = coeffs(3);
delta = coeffs(4);


lim = depth_plot(reco);
export_fig(sprintf('%sdepth_alpha%g_beta%g_gamma%g_delta%g_sigma%g_reco.png', subd, alpha, beta, gamma, delta, sigmaBlur), '-p0.02');
depth_plot(SPADdata, lim);
export_fig(sprintf('%sdepth_alpha%g_beta%g_gamma%g_delta%g_sigma%g_spad.png', subd, alpha, beta, gamma, delta, sigmaBlur), '-p0.02');



disp('Depth images saved.');


% produce ccd image
imwrite(ccd_img/max(ccd_img(:)), sprintf('%sccd_img_alpha%g_beta%g_gamma%g_delta%g_sigma%g.png', subd, alpha, beta, gamma, delta, sigmaBlur));
disp('CCD image saved.');

% export scene
exportScene(reco, 1, sprintf('%sreco_alpha%g_beta%g_gamma%g_delta%g_sigma%g.vtk', subd, alpha, beta, gamma, delta, sigmaBlur));
disp('Scene exported.');

close all

end