clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
% load("/work/Wei/Projects/WholeFishAnalyss/dat/opticalFlowTestData.mat","dat2_crop");

load("/work/Wei/Projects/WholeFishAnalyss/dat/221124_dat2.mat","dat2");
dat=dat2;
dat_ref=double(dat(:,:,:,1));

dat_corrected1=zeros(size(dat),"uint16");
dat_corrected2=dat_corrected1;
for t=1:size(dat,4)
    tic;
    disp(t+"/"+size(dat,4));
    dat_mov=double(dat(:,:,:,t));
    phi_current=getMotion_Wei(dat_mov,dat_ref);
%     dat_corrected1(:,:,:,t)=correctMotion_Wei(dat_mov,phi_current);
    dat_corrected2(:,:,:,t)=correctMotion_Wei(dat_mov,phi_current);
    toc;
end

% z=5;
% vid1=(squeeze(double(dat(:,:,z,:)))-100)/500;
% vid2=(squeeze(double(dat_corrected2(:,:,z,:)))-100)/500;
% implay(cat(2,vid1,vid2))
cd("/work/Wei/Projects/WholeFishAnalyss/dat/221219");
for z=1:size(dat,3)
    out=cat(2,squeeze(dat(:,:,z,:)),squeeze(dat_corrected2(:,:,z,:)));
    tifwrite(out, "corrected_"+z+".tif");
end
