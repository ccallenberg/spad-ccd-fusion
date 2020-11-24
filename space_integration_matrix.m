% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function K = space_integration_matrix(w, h, t)

k = repmat(1:t, [w*h, 1]);
k = k(:);

l = 1:w*h*t;

K = sparse(k, l, ones(w*t*h, 1), t, w*h*t);


end