
% set backup data in case of reloading
data1 = double(dat2_crop(:,:,:,1));
data1_backup = data1;
data2 = double(dat2_crop(:,:,:,2));
data2_backup = data2;

SZ=size(data1_backup);

sigma_gaussian = 2;         % smoothness
layer_num = 3;              % pyramid layer num
tform_rigid = zeros(3,3);   % save result and loss
loss_rigid = zeros(1,3);
for layer = layer_num:-1:0
    if layer > -1
        % get image of current layer
        data1 = imresize3(data1_backup, [round(SZ(1:2)/2^layer) SZ(3)]);
        data2 = imresize3(data2_backup, [round(SZ(1:2)/2^layer) SZ(3)]);
    else
        data1 = data1_backup;
        data2 = data2_backup;
    end
    [x,y,z,t] = size(data1);
    % lambda = 0.02;
    pad_size = [10 10 6];  
    step = 1e-6;     % for calculate gradient
    % lr = 0.0001;    
    % decay = 0.9;
    
    % pad image
    data1_pad = padarray(data1,pad_size,'replicate');
    data2_pad = padarray(data2,pad_size,'replicate');
    gt2 = data2;
    
    % initilize the transform of each layer
    if layer == layer_num
        phi_current = gpuArray(zeros(x,y,z,3));
    else
        phi_current_temp = phi_current*2;
        phi_current = gpuArray(zeros(x,y,z,3));  
        phi_current(:,:,:,1) = unique(phi_current_temp(:,:,:,1));
        phi_current(:,:,:,2) = unique(phi_current_temp(:,:,:,2));
        phi_current(:,:,:,3) = unique(phi_current_temp(:,:,:,3));
    end
    
    % phi_current = gpuArray(phi_initial(:,:,:,:,tt));
    [x_ind,y_ind,z_ind] = ind2sub(size(data1),1:x*y*z);
    
    tic;
    loss = gpuArray(zeros(100000,1));
    time = gpuArray(zeros(100000,1));
    
    for iter = 1:5
        phi_previous = phi_current;
        phi_gradient = gpuArray(zeros(x,y,z,3));
        x_bias = reshape(phi_previous(:,:,:,1),[1 x*y*z]);
        y_bias = reshape(phi_previous(:,:,:,2),[1 x*y*z]);
        z_bias = reshape(phi_previous(:,:,:,3),[1 x*y*z]);
       
        % get tranformed data
        x_new = x_ind + x_bias;
        y_new = y_ind + y_bias;
        z_new = z_ind + z_bias;
        data1_tran = interp3(data1_pad,y_new+pad_size(2),x_new+pad_size(1),z_new+pad_size(3));
       
        % calculate xyz gradient
        x_new = x_new + step;
        data1_x_incre = interp3(data1_pad,y_new+pad_size(2),x_new+pad_size(1),z_new+pad_size(3));
       
        x_new = x_new - step;
        y_new = y_new + step;
        data1_y_incre = interp3(data1_pad,y_new+pad_size(2),x_new+pad_size(1),z_new+pad_size(3));
       
        y_new = y_new - step;
        z_new = z_new + step;
        data1_z_incre = interp3(data1_pad,y_new+pad_size(2),x_new+pad_size(1),z_new+pad_size(3));
       
    
        % get gradient and hessian matrix
        Ix = reshape((data1_x_incre - data1_tran)/step, [x y z]);
        Iy = reshape((data1_y_incre - data1_tran)/step, [x y z]);
        Iz = reshape((data1_z_incre - data1_tran)/step, [x y z]);
        It = reshape(data1_tran-gt2(:)', [x y z]);
    
        Ixx = imfilter(Ix.^2,ones(5,5,3),'replicate','same','corr');
        Ixy = imfilter(Ix.*Iy,ones(5,5,3),'replicate','same','corr');
        Ixz = imfilter(Ix.*Iz,ones(5,5,3),'replicate','same','corr');
        Iyy = imfilter(Iy.^2,ones(5,5,3),'replicate','same','corr');
        Iyz = imfilter(Iy.*Iz,ones(5,5,3),'replicate','same','corr');
        Izz = imfilter(Iz.^2,ones(5,5,3),'replicate','same','corr');
        Ixt = imfilter(Ix.*It,ones(5,5,3),'replicate','same','corr');
        Iyt = imfilter(Iy.*It,ones(5,5,3),'replicate','same','corr');
        Izt = imfilter(Iz.*It,ones(5,5,3),'replicate','same','corr');
    
        phi_gradient=getFlow3(Ixx,Ixy,Ixz,Iyy,Iyz,Izz,Ixt,Iyt,Izt);
    
        % update transfrom
        phi_gradient = mean(mean(mean(phi_gradient,1,'omitnan'),2,'omitnan'),3,'omitnan');
        [phi_gradient(1) phi_gradient(2) phi_gradient(3)]  
        phi_current = phi_current + phi_gradient;
    
    
    
        mse = mean((data1_tran(:) - gt2(:)).^2);
        fprintf('Iteration %d\n Current error:%f Time:%f\n',iter, mse, toc);
        loss(iter) = mse;
        time(iter) = toc;
    end

end
loss = gather(loss(1:iter));
time = gather(time(1:iter));
phi_current = gather(phi_current);
ux = phi_current(:,:,:,1);
uy = phi_current(:,:,:,2);
uz = phi_current(:,:,:,3);
unique(ux)
unique(uy)
unique(uz)
