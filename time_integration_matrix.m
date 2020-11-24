% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function I = time_integration_matrix(w, h, t)

i = kron(1 : w*h, ones(t, 1));
j = repmat(0 : w * h : w * h * t - 1, [1, w * h]) + kron(1 : w * h, ones(1, t));
I = sparse(i, j, ones(w*t*h, 1), w*h, w*h*t);

end