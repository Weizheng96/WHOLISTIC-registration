clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% set parameters
filePath="/ssd1/Pubilic Data/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

anaFilePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/anat/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf001.nd2";

anaCorrectedPath="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/ref/" + ...
    "ref_ch2_corrected.ome.tiff";

correctedFileName="/ssd1/Wei/230119_f389/230119_f389-230216-2Dv2_jump20_penalty1/Corrected.ome.tiff";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/" + ...
    "230119_f389-230323-v24d1_jump20_fast_r12p1";

option.larer=3;
option.iter=10;
option.r=12;
smoothPenalty=1;
refLength=5;
refJump =2;
initialLength=5;
smFactor=50;
thresFactor=5;
%%
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%%
reader = bfGetReader(convertStringsToChars(anaFilePath));
[~,~,Z_ref,~,~,option.zRatio_ref]=readMeta(reader);
Z=Z_ref;
option.zRatio=option.zRatio_ref;

reader = bfGetReader(convertStringsToChars(anaCorrectedPath));
dat_ref=readOneFrame_single(reader,1,1);

reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z_mov,~,~,option.zRatio_mov]=readMeta(reader);

reader = bfGetReader(convertStringsToChars(correctedFileName));
omeMeta = reader.getMetadataStore();T = omeMeta.getPixelsSizeT(0).getValue(); 


dat_ref_norm=getHighFrequencyComponent(dat_ref,smFactor);
option.mask_ref=getMask(dat_ref_norm,thresFactor);
muRef=mean(dat_ref_norm,'all');sigmaRef=std(dat_ref_norm,0,'all');
%%
dat_mov_Raw=readOneFrame_single(reader,1,2);
zLst=getZLst(dat_ref,dat_mov_Raw,option);
option.mask_movPad=true(size(dat_ref));
option.mask_movPad(:,:,zLst)=false;
%%
tRange=1:T;
dat_corrected1=zeros([X,Y,Z_mov,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z_mov,length(tRange)],"uint16");
for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    dat_mov_Raw=readOneFrame_single(reader,t,2);
    toc;
    % get reference image
    disp("normalize data (1)...");
    dat_mov=resizeMov_v2(dat_mov_Raw,Z,zLst);
    dat_mov_norm=getHighFrequencyComponent(dat_mov,smFactor);
    dat_mov_norm=meanStdNormalization(dat_mov_norm,muRef,sigmaRef);
    option.mask_mov=getMask(dat_mov_norm,thresFactor);
    toc;
    % motion correction
    disp("estimate motion...");
    [~,~,x_new,y_new,z_new]=getMotion_Wei_v24d1(dat_mov_norm,dat_ref_norm,smoothPenalty,option);
    toc
    disp("correct motion...");
    dat_ch1=readOneFrame_single(reader,t,1);
    dat_ch1=resizeMov(dat_ch1,Z,option);
    temp=correctMotion_Wei_v3(dat_ch1,x_new,y_new,z_new);
    dat_corrected1(:,:,:,tCnt)=temp(:,:,zLst);
    temp=correctMotion_Wei_v3(dat_mov,x_new,y_new,z_new);
    dat_corrected2(:,:,:,tCnt)=temp(:,:,zLst);
    toc;
    % motion correction
    % save motion
%     disp("save motion...");
%     save(resPathName+"/motion_"+t+".mat","motion_current");
%     toc;
end

%% save the first result
disp("save result (2)...");
cd(resPathName);
out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
out1=reshape(out,X,2*Y,Z_mov,1,length(tRange));
out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
out2=reshape(out,X,2*Y,Z_mov,1,length(tRange));
bfsave(cat(4,out1,out2), 'Original_Corrected.ome.tiff');