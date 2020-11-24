% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function A_3d = build_A3d(w, h, t, s_spad, sigmaBlur)


%% build matrices P and B

f = floor(w/s_spad); 
kernelType = 'gaussian';
kernelSize = floor(4*sigmaBlur + 1);

P_sub = zeros(s_spad*s_spad, w*h);
for i = 1:s_spad
    for j = 1:s_spad
        for k = 1:f
            P_sub((i-1)*s_spad+j, ((i-1)*f+k-1)*w + (j-1)*f + (1 : f)) = 1;
        end
    end
end

% pad for right size of blurred image
P_sub = reshape(P_sub, [size(P_sub, 1), w, h]);
P_sub = padarray(P_sub, [0, (kernelSize - 1)/2, (kernelSize - 1)/2]);
P_sub = sparse(reshape(P_sub, [size(P_sub, 1), (w+kernelSize-1) * (h+kernelSize-1)]));

P = sparse(P_sub);

if strcmp(kernelType, 'gaussian')
    kernel = fspecial('gaussian', kernelSize, sigmaBlur);
elseif strcmp(kernelType, 'disk')
    kernel = fspecial('disk', sigmaBlur);
    kernel = padarray(kernel, floor(0.5*[kernelSize-2*sigmaBlur, kernelSize-2*sigmaBlur]));
elseif strcmp(kernelType, 'box')
    kernel = zeros(kernelSize);
    kernel(floor((kernelSize-sigmaBlur*2)/2)+1:end-floor((kernelSize-sigmaBlur*2)/2), floor((kernelSize-sigmaBlur*2)/2)+1:end-floor((kernelSize-sigmaBlur*2)/2)) = 1/(2*sigmaBlur+1)^2;
end


B = sparse(convmtx2(kernel, [w, h]));




%% build matrix S that selects ~8% of SPAD pixel area


if 1 
    fillFactorMask = zeros(w, h);
    for x = 1:w
        for y = 1:h
            %         if ((x-4)/8 - floor((x-4)/8))*8 < 2 && ((y-4)/8 - floor((y-4)/8))*8 < 2  % central position
            if mod(x+w/s_spad-1, w/s_spad) == 0 && mod(y+h/s_spad-1, h/s_spad) == 0
                fillFactorMask(x:x+floor((w/s_spad)/2)-1, y:y+floor((h/s_spad)/2)-1) = 1;
            end
        end
    end
    
    % account for blur matrix size (padding)
    fillFactorMask = padarray(fillFactorMask, [(kernelSize - 1)/2, (kernelSize - 1)/2]);
    J = 1:(w+kernelSize-1)*(h+kernelSize-1);
    S = sparse(find(fillFactorMask(:)), J(find(fillFactorMask(:))), ones(nnz(fillFactorMask(:)), 1), (w+kernelSize-1)*(h+kernelSize-1), (w+kernelSize-1)*(h+kernelSize-1));
    
else
    
    S = speye(size(B, 1));
    
end

%% Combine P, S and B and build big matrix for all time frames

A = P*S*B;

A_3d = kron(speye(t), A);

end