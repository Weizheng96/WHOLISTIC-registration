function [Ix,Iy]=getSpatialGradientInOrg2D_Wei(data_raw,phi_current)
%% set parameters
step=1;
%% extract motion
[x,y] = size(data_raw);
[x_ind,y_ind] = ind2sub(size(data_raw),1:x*y);
x_bias = reshape(phi_current(:,:,1),[1 x*y]);
y_bias = reshape(phi_current(:,:,2),[1 x*y]);

%% pixel location
x_new = x_ind + x_bias; x_new=max(x_new,1); x_new=min(x_new,x);
y_new = y_ind + y_bias; y_new=max(y_new,1); y_new=min(y_new,y);

%% get gradient
data1_incre = interp2(data_raw,y_new,rangeConstrain(x_new+step,1,x));
data1_decre = interp2(data_raw,y_new,rangeConstrain(x_new-step,1,x));
Ix = (data1_incre - data1_decre)/(2*step);
% clear data1_incre data1_decre

data1_incre = interp2(data_raw,rangeConstrain(y_new+step,1,y),x_new);
data1_decre = interp2(data_raw,rangeConstrain(y_new-step,1,y),x_new);
Iy = (data1_incre - data1_decre)/(2*step);
clear data1_incre data1_decre


%% reshape
Ix = reshape(Ix, [x y]);
Iy = reshape(Iy, [x y]);

end