% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function exportScene( scene, f, filename )

    [X Y Z] = ndgrid(1:f:size(scene, 1), 1:f:size(scene, 2), 1:f:size(scene, 3));
    x = X(:);
    y = Y(:);
    z = Z(:);
    n = numel(x);
    S = zeros(1, n);
    for i = 1:n
        S(i) = scene(x(i), y(i), z(i));
    end
    s = S(:);
    
    x(s == 0) = [];
    y(s == 0) = [];
    z(s == 0) = [];
    s(s == 0) = [];
    
    x = single(x); 
    y = single(y); 
    z = single(z); 
    s = single(s); 
    
    title = 'scene';
    display('scene exported');
    f = fopen([filename '.raw'],'wb');
    fwrite(f,single(scene),'single');
    fclose(f);

end

