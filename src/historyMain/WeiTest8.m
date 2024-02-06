clear;clc;
addpath(genpath("/work/Wei/Projects/WholeFishAnalyss/src"));
% load("/work/Wei/Projects/WholeFishAnalyss/dat/opticalFlowTestData.mat","dat2_crop");

load("/work/Wei/Projects/WholeFishAnalyss/dat/221124_dat2.mat","dat2");
load("/work/Wei/Projects/WholeFishAnalyss/dat/221124_dat1.mat","dat1");
dat=dat2;
dat_ref=double(dat(:,:,:,1));

dat_corrected1=zeros(size(dat),"uint16");
dat_corrected2=dat_corrected1;

smoothPenalty=1;
for t=45:55%1:size(dat,4)
    tic;
    disp(t+"/"+size(dat,4));
    dat_mov=double(dat(:,:,:,t));
    phi_current=getMotion_Wei_v15d2(dat_mov,dat_ref,smoothPenalty);
    dat_corrected1(:,:,:,t)=correctMotion_Wei_v2(double(dat1(:,:,:,t)),phi_current);
    dat_corrected2(:,:,:,t)=correctMotion_Wei_v2(dat_mov,phi_current);
    toc;
end

% z=4;
% vid1=(squeeze(double(dat(:,:,z,:)))-100)/200;
% vid2=(squeeze(double(dat_corrected2(:,:,z,:)))-100)/200;
% implay(cat(2,vid1,vid2))
% 
% vid1=(squeeze(double(dat1(:,:,z,:)))-100)/200;
% vid2=(squeeze(double(dat_corrected1(:,:,z,:)))-100)/200;
% implay(cat(2,vid1,vid2))
% 
% implay(double(dat_corrected2(:,:,:,t))/300)
% 
% implay(double(dat2(:,:,:,t))/300)

%%
% tempz=4;
% im=dat_corrected2(:,:,tempz,t)/400;
% imshow(im);
% [Y,X] = meshgrid(1:size(im,2),1:size(im,1));
% U = gather(phi_current(:,:,tempz,1));
% V = gather(phi_current(:,:,tempz,2));
% hold on;
% quiver(Y,X,V,U,0)
%%
% tempz=4;
% x=1200:1700;y=800:1200;
% im=dat_mov(x,y,tempz)/400;
% imshow(im);
% [Y,X] = meshgrid(y,x);
% U = gather(phi_current(x,y,tempz,1));
% V = gather(phi_current(x,y,tempz,2));
% hold on;
% quiver(Y,X,V,U,0)

%%
pathname="/work/Wei/Projects/WholeFishAnalyss/dat/221124_f338/v15d2_r5_l3_iter20_penalty1";
if ~exist(pathname,"dir")
    mkdir(pathname);
end
cd(pathname);

for z=4%1:size(dat,3)
    out=cat(2,squeeze(dat1(:,:,z,:)),squeeze(dat_corrected1(:,:,z,:)));
    tifwrite(out, "corrected_ch1_"+z+".tif");
end

for z=4%1:size(dat,3)
    out=cat(2,squeeze(dat(:,:,z,:)),squeeze(dat_corrected2(:,:,z,:)));
    tifwrite(out, "corrected_ch2_"+z+".tif");
end