dat_ref=ones(100,10,5).*[11:110]';
dat_mov=ones(100,10,5).*[1:100]';

phi_current=getMotion_Wei_v9(dat_mov,dat_ref,0);
%%
dat=dat2;
dat_ref=double(dat(:,:,:,1));
dat_mov=double(dat(:,:,:,52));
phi_current=getMotion_Wei_v9(dat_mov,dat_ref,1);

%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);
phi_current=getMotion_Wei_v9(dat_mov,dat_ref,0);
%%
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);
phi_current=getMotion_Wei_v10(dat_mov,dat_ref,0);
%%
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);
phi_current=getMotion_Wei_v11(dat_mov,dat_ref,1/400^2);
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);
phi_current=getMotion_Wei_v12(dat_mov,dat_ref,0);
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,1:end-27,1:end-1);
phi_current=getMotion_Wei_v10(dat_mov,dat_ref,0);
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);
% phi_current=getMotion_Wei_v14(dat_mov,dat_ref,(1/400)^2);
phi_current=getMotion_Wei_v14(dat_mov,dat_ref,0);
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);
% phi_current=getMotion_Wei_v14(dat_mov,dat_ref,(1/400)^2);
phi_current=getMotion_Wei_v10(dat_mov,dat_ref,0);
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);
phi_current=getMotion_Wei_v15d2(dat_mov,dat_ref,0.0001);
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);
phi_current=getMotion_Wei_v15d3(dat_mov,dat_ref,0.000001);
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);

option.larer=0;              % pyramid layer num
option.iter=100;
option.r=5;

phi_current=getMotion_Wei_v15d4(dat_mov,dat_ref,0.0001,option);
phi_current=getMotion_Wei_v15d4(dat_mov,dat_ref,0.000001,option);
phi_current=getMotion_Wei_v15d4(dat_mov,dat_ref,0,option);

%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end-1);
dat_mov=dat_raw(28:end,28:end,2:end);

option.larer=0;              % pyramid layer num
option.iter=100;
option.r=5;

phi_current=getMotion_Wei_v15d5(dat_mov,dat_ref,0.0001,option);
phi_current=getMotion_Wei_v15d5(dat_mov,dat_ref,0.000001,option);
phi_current=getMotion_Wei_v15d5(dat_mov,dat_ref,0,option);
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0.5,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end);
dat_mov=dat_raw(28:end,28:end,1:end);

option.larer=0;              % pyramid layer num
option.iter=100;
option.r=5;
option.zRatio=27;
option.motion=[];
option.tempz=11;

phi_current=getMotion_Wei_v17d1(dat_mov,dat_ref,1e-10,option);
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0.5,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end);
dat_mov=dat_raw(28:end,28:end,1:end);

option.larer=0;              % pyramid layer num
option.iter=1000;
option.r=5;
option.zRatio=27;
option.motion=[];
option.MomentumDecayRate=0.9;
option.tempz=11;

phi_current=getMotion_Wei_v19d1(dat_mov,dat_ref,1e-10,option);

%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0.5,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end);
dat_mov=dat_raw(28:end,28:end,1:end);

option.larer=3;              % pyramid layer num
option.iter=50;
option.r=5;
option.zRatio=27;
option.motion=[];
option.MomentumDecayRate=0.5;
option.movRange=5;
option.tempz=11;

tic
phi_current=getMotion_Wei_v17d8(dat_mov,dat_ref,1e-10,option);
toc

dat_mov_corrected=correctMotion_Wei_v2(dat_mov,phi_current);
implay(dat_mov_corrected)
%%
x = [-270:270];
y = normpdf(x,0,81);
dat_ref=pagemtimes(y.*y',reshape(normpdf(-10:10,0.5,3),1,1,21));
dat_raw=dat_ref/max(dat_ref,[],'all');
dat_ref=dat_raw(1:end-27,1:end-27,1:end);
dat_mov=dat_raw(28:end,28:end,1:end);

option.larer=3;              % pyramid layer num
option.iter=50;
option.r=5;
option.zRatio=27;
option.motion=[];
option.MomentumDecayRate=0.9;
option.movRange=5;
option.tempz=11;

phi_current=getMotion_Wei_v19d3(dat_mov,dat_ref,1e-10,option);
dat_mov_corrected=correctMotion_Wei_v2(dat_mov,phi_current);
implay(dat_mov_corrected)


