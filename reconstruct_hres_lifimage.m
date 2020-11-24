% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function reco = reconstruct_hres_lifimage(SPADdata, ccd_img, coeffs, highResolution, sigmaBlur)

alpha = coeffs(1);
beta  = coeffs(2);
gamma = coeffs(3);
delta = coeffs(4);


s_spad = size(SPADdata, 1);
t = size(SPADdata, 3);
w = highResolution;
h = highResolution;



disp('Starting cvx now, this might take a while...');



% build necessary matrices
A_3d = build_A3d(w, h, t, s_spad, sigmaBlur);
I = time_integration_matrix(w, h, t);
K1 = space_integration_matrix(w, h, t);
K2 = space_integration_matrix(s_spad, s_spad, t);

% TV matrix
fwddiff = [0  0  0; ...
    0 -1  0; ...
    0  1  0];
D2 = [ ...
    convmtx2(fwddiff, w, h*t); ...
    convmtx2(fwddiff', h, w*t);
    ];


meas3d = SPADdata(:);


cvx_begin

variable x(w*h*t)

minimize( ...
    norm(A_3d*x - meas3d, 2) ...              
    +   alpha * norm(I*x-ccd_img(:), 2) ...             
    +   beta  * norm(K1*x - K2*meas3d, 2) ...           
    +   gamma * norm(x, 1) ...                                  
    +   delta * norm(D2*x, 1) ...
    );

subject to
x >= 0

cvx_end
reco = reshape(x, [w, h, t]);



end


