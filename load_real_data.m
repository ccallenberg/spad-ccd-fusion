% Code for Scientific Reports paper "Super-Resolution Time-Resolved Imaging using Computational Sensor Fusion" by C. Callenberg et al.
% author: Clara Callenberg <callenbe@cs.uni-bonn.de>
% University of Bonn

function [SPADdata, ccd_img] = load_real_data(path, datasetname)

reverse = false;

switch datasetname
    case 'steps'
        load([path '\measurements\steps_0-6-12.mat']);
    case 'letters'
        load([path '\measurements\letters_board_0-6-12.mat']);
    case 'waterglass'
        load([path '\measurements\water_glass.mat']);
    case 'basketball'
        load([path '\measurements\basketball.mat']);
        reverse = true;
    case 'golfball'
        load([path '\measurements\golf_ball.mat']);
        reverse = true;
end

% reverse dataset if necessary (some datasets have reversed temporal
% dimension)
if reverse
    SPAD_5mm = SPAD_5mm(:,:,end:-1:1);
    SPAD_10mm = SPAD_10mm(:,:,end:-1:1);
    SPAD_7mm = SPAD_7mm(:,:,end:-1:1);
end

% get corresponding crop from CCD image

initAlign = exist('ccdstart1') && exist('ccdstart2');
if ~initAlign
    ccdstart1 = 210;
    ccdstart2 = 199;
end

switch datasetname
    case 'steps'
        t_start = 79;    
        t_stop  = 110;  
    case 'letters'
        t_start = 90;       
        t_stop  = 140;     
    case 'waterglass'
        t_start = 98;      
        t_stop  = 141;      
    case 'golfball'
        t_start = 80;
        t_stop  = 104;
    case 'basketball'
        t_start = 78;     
        t_stop  = 111;       
end


s_spad = size(SPAD_10mm, 1);

t = t_stop-t_start+1;
meas3d = reshape(SPAD_10mm(:,:,t_start:t_stop), [s_spad*s_spad*t, 1]);

w = 96;
h = 96;

% aligning SPAD and ccd...

ccd_img = EMCCD_no_crop(ccdstart1+2:ccdstart1+2+95, ccdstart2+3:ccdstart2+3+95);
normint = sum(ccd_img(:)) / sum(meas3d(:));
ccd_img = ccd_img / normint;

% adjust contrast in CCD image

ccd_img_hc = ccd_img;

ccd_img_hc(ccd_img > prctile(ccd_img(:), 99.5)) = prctile(ccd_img(:), 99.5);
ccd_img_hc = ccd_img_hc - min(ccd_img_hc(:));
ccd_img_hc = ccd_img_hc/max(ccd_img_hc(:));
ccd_img_hc = ccd_img_hc * sum(ccd_img(:)) / sum(ccd_img_hc(:));

ccd_img = ccd_img_hc;

normint = sum(ccd_img(:)) / sum(meas3d(:));
ccd_img = ccd_img / normint;
    

SPADdata = reshape(meas3d, s_spad, s_spad, t);
fprintf('Dataset >%s< loaded.\n', datasetname);


end