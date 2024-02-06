function [Ix,Iy]=getSpatialGradientInOrg2D_Wei_v2(data_raw,phi_current)
%% set parameters
step=1;
%% extract motion
[x,y,z] = size(data_raw);
[x_ind,y_ind,z_new] = ind2sub(size(data_raw),(1:x*y*z));
x_bias = reshape(phi_current(:,:,:,1),[1 x*y*z]);
y_bias = reshape(phi_current(:,:,:,2),[1 x*y*z]);

%% pixel location
x_new = x_ind + x_bias; x_new=max(x_new,1); x_new=min(x_new,x);
y_new = y_ind + y_bias; y_new=max(y_new,1); y_new=min(y_new,y);
z_new = single(z_new);
clear x_bias y_bias z_bias
%% get gradient
data1_incre = interp3(data_raw,y_new,rangeConstrain(x_new+step,1,x),z_new);
data1_decre = interp3(data_raw,y_new,rangeConstrain(x_new-step,1,x),z_new);
Ix = (data1_incre - data1_decre)/(2*step);
% clear data1_incre data1_decre

data1_incre = interp3(data_raw,rangeConstrain(y_new+step,1,y),x_new,z_new);
data1_decre = interp3(data_raw,rangeConstrain(y_new-step,1,y),x_new,z_new);
Iy = (data1_incre - data1_decre)/(2*step);
clear data1_incre data1_decre

%% reshape
Ix = reshape(Ix, [x y z]);
Iy = reshape(Iy, [x y z]);

end