clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
%% file path
filePath="/work/public/Virginia Rutten/230324_f479_ubi_gcamp_bactin2_mcherry_9dpf_hypoxia_tiles/imag_tiles/res";
resPathName="/work/public/Virginia Rutten/Result/230324_f479/230324_f479-230507_HZRv2d2_r5p1";
%% parameters
option.layer=3;
option.iter=10;
option.r=5;
smoothPenalty=1;


frameJump=1;
refLength=5;
refJump =40/frameJump;
initialLength=5;
thresFactor=5;
smFactor=50;
%% generate the folder
if ~exist(resPathName,"dir")
    mkdir(resPathName);
end
%% normalize anatomical template (get fixed template)

%% get valid z slice in moving image
cd(filePath);
% reader = bfGetReader(convertStringsToChars(filePath));
% [X,Y,Z,T,~,option.zRatio]=readMeta(reader);
load("dat0.mat","dat");
[Z,~,X,Y]=size(dat);
T=4565;option.zRatio=100;
%% motion correction
tRange=1:frameJump:T;

dat_corrected1=zeros([X,Y,Z,length(tRange)],"uint16");
dat_corrected2=zeros([X,Y,Z,length(tRange)],"uint16");
motion_history=zeros([X,Y,Z,3,initialLength],"single");

option.motion=zeros([X,Y,Z,3]);
dat_ref=single(permute(dat(:,2,:,:),[3 4 1 2]));
option.mask_ref=getMask(dat_ref,thresFactor);

for tCnt=1:length(tRange)
    tic;
    t=tRange(tCnt)-1;
    disp(t+"/"+T);
    % read data
    disp("read data (1)...");
    load("dat"+t+".mat","dat");
    dat_mov=single(permute(dat(:,2,:,:),[3 4 1 2]));
    option.mask_mov=getMask(dat_mov,thresFactor);
    toc;
    % get reference image
    disp("generate reference...");
    if mod(tCnt-1,refJump)==0
        if tCnt>refLength*refJump
            refRange=(tCnt-refLength*refJump):refJump:(tCnt-refJump);
            dat_ref=single(median(dat_corrected2(:,:,:,refRange),4));
        end
%         dat_ref=updateFloatingTemplate_v3(dat_ref,dat_anaref_norm,thresFactor,optionTemplate,smoothPenaltyTemplate);
        option.mask_ref=getMask(dat_ref,thresFactor);
    end
    toc;
    % motion correction
    disp("correct motion...");
    motion_current=getMotionHZR_Wei_v2d2(dat_mov,dat_ref,smoothPenalty,option);
    correctedCh1=correctMotion_Wei_v2(single(permute(dat(:,1,:,:),[3 4 1 2])),motion_current);
    dat_corrected1(:,:,:,tCnt)=correctedCh1;
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
    % save result
    ImName=num2str(t,"%05.f");
    save(fullfile(resPathName,ImName),"correctedCh1")
end
%% save the first result
% disp("save result (1)...");
% cd(resPathName);
% out=cat(2,readWithTime(reader,tRange,1),dat_corrected1);
% out1=reshape(out,X,2*Y,Z,1,length(tRange));
% out=cat(2,readWithTime(reader,tRange,2),dat_corrected2);
% out2=reshape(out,X,2*Y,Z,1,length(tRange));
% bfsave(cat(4,out1,out2), 'Original_Corrected.ome.tiff');
%%
% disp("save result (1)...");
% cd(resPathName);
% out1=reshape(dat_corrected1,X,Y,Z,1,length(tRange));
% bfsave(out1, 'CorrectedCh1.ome.tiff');