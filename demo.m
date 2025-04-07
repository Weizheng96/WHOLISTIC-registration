%This is a simple demo of WBI registration.
%% add dependency
clear;clc;
addpath(genpath("./src"));

%% set parameters
% data path used for registration
filePath="./data/demo_data.mat";

% number of downsampled pyramid layers.
option.layer=3;

% max number of iteration of each layer.
option.iter=10;

% control patch size. 
option.r=5; % Large patch size give more rigid but more reliable result.

% control smoothness penalty
smoothPenalty_raw=0.01; % Larger smoothness penalty give more smooth motion field. 

% [optional] Z score threshold of unreliable region mask
thresFactor=5; % set thresFactor=inf if all pixel should be considered

% [optional] size threshold unreliable region
maskRange=[5 500]; % set maskRange=[0 inf] if all pixel should be considered

%% load template image and moving imagre
load(filePath,"dat_ref","dat_mov","zRatio");
dat_ref=single(dat_ref);
dat_mov=single(dat_mov);
%% [optional] get unreliable region mask for moving immuning cells
option.mask_ref=getMask(dat_ref,thresFactor);
option.mask_mov=getMask(dat_mov,thresFactor);
option.mask_ref=bwareafilt3_Wei(option.mask_ref,maskRange);
option.mask_mov=bwareafilt3_Wei(option.mask_mov,maskRange);
option.zRatio=zRatio;
%% initialization
[X,Y,Z]=size(dat_ref);
xG=option.r+1:2*option.r+1:X;yG=option.r+1:2*option.r+1:Y;zG=1:Z; % get control point
option.motion=zeros([X,Y,Z,3]); % initial motion field
smoothPenalty=getSmPnltNormFctr(dat_ref,option)*smoothPenalty_raw; % smoothness penalty

%% registration (main function)
disp("correct motion...");
motion_field=getMotionHZR_Wei_v2d2(dat_mov,dat_ref,smoothPenalty,option); % get motion field
dat_cor=correctMotion_Wei_v2(dat_mov,motion_field); %% apply the motion field to get corrected image

%% visulize result of 7th z slice
vis_ref=(dat_ref(:,:,7)-100)/300;
vis_mov=(dat_mov(:,:,7)-100)/300;
vis_cor=(dat_cor(:,:,7)-100)/300;
implay(cat(3,cat(2,vis_ref,vis_ref),cat(2,vis_mov,vis_cor)));
