filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230216-v20_jump20_penalty1";

reader = bfGetReader(convertStringsToChars(filePath));

[X,Y,Z,T,~,option.zRatio]=readMeta(reader);

t_ref=1;t_mov=6641;t_movRef=6621;


dat_ref=readOneFrame_double(reader,t_ref,2);
dat_mov=readOneFrame_double(reader,t_mov,2);

smFactor=50;
dat_refN=getHighFrequencyComponent(dat_ref,smFactor);
dat_movN=getHighFrequencyComponent(dat_mov,smFactor);

IntOrdRef=sort(dat_refN(:));
dat_movNN=histogramNormalize(dat_movN,IntOrdRef);

maskThres=100;

option.larer=3;
option.iter=10;
option.r=5;
option.mask_ref=imdilate(abs(dat_refN)>maskThres,ones(3));
option.mask_mov=imdilate(abs(dat_movNN)>maskThres,ones(3));

smoothPenalty=1;

load(resPathName+"/motion_"+t_movRef+".mat","motion_current");
option.motion=motion_current;
tic
motion_current=getMotion_Wei_v20d3(dat_movNN,dat_refN,smoothPenalty,option);
toc
dat_corrected=correctMotion_Wei_v2(dat_mov,motion_current);


implay((dat_mov-80)/170)
implay((dat_corrected-80)/170)
implay((dat_ref-80)/170)

z=4;r=5;
gridMotion_v2(dat_mov/250,motion_current,z,r)