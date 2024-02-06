dat_corrected1=zeros(size(dat),"uint16");
dat_corrected2=zeros(size(dat),"uint16");
motion_x=zeros(size(dat_corrected2));
motion_y=zeros(size(dat_corrected2));
motion_z=zeros(size(dat_corrected2));
smoothPenalty=1;
for t=1:size(dat,4)
    tic;
    disp(t+"/"+size(dat,4));
    dat_mov=double(dat(:,:,:,t));
    phi_current=getMotion_Wei_v6(dat_mov,dat_ref,smoothPenalty);
    motion_x(:,:,:,t)=phi_current(:,:,:,3);
    motion_y(:,:,:,t)=phi_current(:,:,:,3);
    motion_z(:,:,:,t)=phi_current(:,:,:,3);
    dat_corrected1(:,:,:,t)=correctMotion_Wei(double(dat1(:,:,:,t)),phi_current);
    dat_corrected2(:,:,:,t)=correctMotion_Wei(dat_mov,phi_current);
    toc;
end



z=4;
r=min(double(dat_corrected2(:,:,z,50:55))/400,1);
% motion=sqrt(motion_x(:,:,z,50:55).^2+motion_y(:,:,z,50:55).^2+(motion_z(:,:,z,50:55)*27).^2);
% motion=sqrt(motion_x(:,:,z,50:55).^2+motion_y(:,:,z,50:55).^2);
motion=motion_x(:,:,z,50:55);
g=motion/3;
b=-g;
out=cat(3,r,g,b);
implay(out)

% implay(double(dat_corrected2(:,:,5,50:55))/400)
% implay(double(dat(:,:,:,52))/400)

motion_x_raw=motion_x;
motion_y_raw=motion_y;
motion_z_raw=motion_z;
dat_corrected2_raw=dat_corrected2;

z=5;
r=double(dat_corrected2_raw(:,:,z,50:55))/400;
g=motion_x_raw(:,:,z,50:55)/3;
b=-g;
out=cat(3,r,g,b);
implay(out)

z=4
implay(double(dat_corrected2(:,:,z,47:55))/400)

z=4
implay(double(dat_corrected1(:,:,z,47:55))/400)

implay(double(dat(:,:,z,50:55))/400)


%%
% histogram(phi_current(:,:,:,3))
% hold on;
% histogram(Diff(:,:,:,3))
% 
% for beta=0.01:-0.00001:0.005
%     a=phi_current-Diff*beta;
%     Diff2=getDifferenceWithNei(a);
%     
%     edges=-5:0.05:5;
%     histogram(Diff,edges);
%     hold on;
%     histogram(Diff2,edges);
%     hold off;
%     ylim([0 20*10^3]);
%     title(beta);
%     pause(0.1)
% end