clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% file path
filePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/imag/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf002.nd2";

anaFilePath="/work/public/Virginia Rutten/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf/exp0/anat/" + ...
    "230119_f389_ubi_gcamp_bact_mcherry_8849_7dpf001.nd2";

resPathName="/work/Wei/Projects/WholeFishAnalyss/dat/230119_f389/230119_f389-230418_HZRv2d2_r5p1_v24d1_r12p10_jump20";
%% parameters
option.layer=3;
option.iter=10;
option.r=5;
smoothPenalty=1;

optionTemplate.layer=3;
optionTemplate.iter=10;
optionTemplate.r=12;
smoothPenaltyTemplate=10;


frameJump=20;
refLength=5;
refJump =40/frameJump;
initialLength=5;
thresFactor=5;
smFactor=50;
%% generate the folder
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%% correct anatomic image
[dat_ana_corrected2,optionTemplate.zRatio]=correctAnaFile(anaFilePath,resPathName); % saved as "ref_ch2_corrected.ome.tiff"
%% normalize anatomical template (get fixed template)
dat_anaref_norm=getHighFrequencyComponent(dat_ana_corrected2,smFactor);
optionTemplate.mask_ref=getMask(dat_anaref_norm,thresFactor);
optionTemplate.zRatio_ref=optionTemplate.zRatio;
optionTemplate.muRef=mean(dat_anaref_norm,'all');
optionTemplate.sigmaRef=std(dat_anaref_norm,0,'all');
optionTemplate.smFactor=smFactor;
%% get valid z slice in moving image
reader = bfGetReader(convertStringsToChars(filePath));
[X,Y,Z,T,~,optionTemplate.zRatio_mov]=readMeta(reader);
option.zRatio=optionTemplate.zRatio_mov;
dat_mov_Raw=readOneFrame_single(reader,1,2);
optionTemplate.zLst=getZLst(dat_anaref_norm,dat_mov_Raw,optionTemplate);
optionTemplate.mask_movPad=true(size(dat_anaref_norm));
optionTemplate.mask_movPad(:,:,optionTemplate.zLst)=false;
%% motion correction
tRange=1:frameJump:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength],"single");

option.motion=zeros([X,Y,Z,3]);
dat_ref=readOneFrame_single(reader,1,2);
option.mask_ref=getMask(dat_ref,thresFactor);

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt);
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    dat_mov=readOneFrame_single(reader,t,2);
    option.mask_mov=getMask(dat_mov,thresFactor);
    toc;
    % get reference image
    disp("generate reference...");
    if mod(tCnt-1,refJump)==0
        if tCnt>refLength*refJump
            refRange=(tCnt-refLength*refJump):refJump:(tCnt-refJump);
            dat_ref=single(median(dat_corrected2(:,:,:,refRange),4));
        end
        dat_ref=updateFloatingTemplate_v3(dat_ref,dat_anaref_norm,thresFactor,optionTemplate,smoothPenaltyTemplate);
        option.mask_ref=getMask(dat_ref,thresFactor);
    end
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotionHZR_Wei_v2d2(dat_mov,dat_ref,smoothPenalty,option);
    dat_corrected1(:,:,:,tCnt)=correctMotion_Wei_v2(readOneFrame_double(reader,t,1),motion_current);
    dat_corrected2(:,:,:,tCnt)=correctMotion_Wei_v2(dat_mov,motion_current);
    toc;
    % motion correction
    disp("initialize motion...");
    [motion_history,BestMotion]=updateMotionHistory(motion_current,motion_history);
    option.motion=BestMotion;
    toc;
    % save motion
%     disp("save motion...");
%     save(resPathName+"/motion_first_"+t+".mat","motion_current");
%     toc;
end
%% save the first result
disp("save result (1)...");
cd(resPathName);
out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
out1=reshape(out,X,2*Y,Z,1,length(tRange));
out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
out2=reshape(out,X,2*Y,Z,1,length(tRange));
bfsave(cat(4,out1,out2), 'Original_Corrected.ome.tiff');