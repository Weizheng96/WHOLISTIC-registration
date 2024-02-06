function motion_current=getMotion2D_Wei_v4(dat_mov,dat_ref,smoothPenalty_raw,option)
%% v4: based on v3, less memory

%% parameters need to adjust
layer_num=option.layer;              % pyramid layer num
iterNum=option.iter;
r=option.r;

%% parameters don't need to adjust
SZ=size(dat_mov);
movRange=5;
%% multi-scale loop
for layer = layer_num:-1:0

    %% dowmsample for current scale
    data1 = gpuArray(imresize3(dat_mov, [round(SZ(1:2)/2^layer) SZ(3)]));
    data2 = gpuArray(imresize3(dat_ref, [round(SZ(1:2)/2^layer) SZ(3)]));
    [x,y,z] = size(data1);
    
    %% initilize the motion of each layer
    if layer == layer_num
        if isfield(option,'motion') && ~isempty(option.motion)
            motion_current = gpuArray(zeros(x,y,z,2,"single"));
            motion_current(:,:,:,1)=imresize3(option.motion(:,:,:,1),[x,y,z])/(SZ(1)/x);
            motion_current(:,:,:,2)=imresize3(option.motion(:,:,:,2),[x,y,z])/(SZ(2)/y);
        else
            motion_current = gpuArray(zeros(x,y,z,2,"single"));
        end
    else
        motion_current_temp=gather(motion_current);
        motion_current=zeros(x,y,z,2,"single");
        motion_current(:,:,:,1) = imresize3(motion_current_temp(:,:,:,1), [x,y,z],"linear")*2;
        motion_current(:,:,:,2) = imresize3(motion_current_temp(:,:,:,2), [x,y,z],"linear")*2;
        motion_current=gpuArray(motion_current);
    end
    
    [x_ind,y_ind,z_ind] = ind2sub(size(data1),1:x*y*z);
    x_ind=gpuArray(single(x_ind));y_ind=gpuArray(single(y_ind));z_ind=gpuArray(single(z_ind));
    %% initialize mask
    mask_ref=imresize3(single(option.mask_ref),[x,y,z])>0;
    mask_mov=imresize3(single(option.mask_mov),[x,y,z]);
    %% initial old error
    oldError=inf(3,1);
    %% penalty parameters
    smoothPenalty=smoothPenalty_raw;
    patchConnectNum=(r*2+1)^2;
    smoothPenaltySum=smoothPenalty*patchConnectNum;
    %% get patch
    xG=r+1:2*r+1:x;yG=r+1:2*r+1:y;

    %% update motion loop
%     fprintf("\nDownsample:"+layer+"\n");
%     toc
    for iter = 1:iterNum
        %% get corrected data
        data1_tran=correctMotion2D_Wei_v3(data1,motion_current,x_ind,y_ind,z_ind);  
        mask_mov_current=correctMotion2D_Wei_v3(mask_mov,motion_current,x_ind,y_ind,z_ind)>0;  
        mask= mask_mov_current|mask_ref;
        %% get temporal difference
        It = data2-data1_tran;
        It = imfilter(It,ones(3)/9,'replicate','same','corr');
        It(mask)=0;
        %% get neighbor motion difference
        neiDiff=getNeiDiff(motion_current(xG,yG,:,:),1);
        neiSum=smoothPenaltySum*neiDiff;
        %% calculate error and decide to stop or not
        [diffError,penaltyError]=calError_v2(It,neiDiff,smoothPenaltySum);
        currentError=diffError+penaltyError;
%         fprintf("Downsample:"+layer+"\tIter:"+iter+"\tError:\t"+currentError+"\tDiff:\t"+diffError+"\n");

        if iter == iterNum || sum(oldError<=currentError)>1
            break;
        else
%             disp(currentError);
            oldError(1:end-1)=oldError(2:end);
            oldError(end)=currentError;
        end
        %% get motion update of control points
        [Ix,Iy]=getSpatialGradientInOrg2D_Wei_v3(data1,motion_current,x_ind,y_ind,z_ind);
        Ix(mask)=0;Iy(mask)=0;

        AverageFilter=ones(r*2+1);

        Ixx = imfilter(Ix.^2 ,AverageFilter,'replicate','same','corr');
        Ixy = imfilter(Ix.*Iy,AverageFilter,'replicate','same','corr');
        Iyy = imfilter(Iy.^2 ,AverageFilter,'replicate','same','corr');
        Ixt = imfilter(Ix.*It,AverageFilter,'replicate','same','corr');
        Iyt = imfilter(Iy.*It,AverageFilter,'replicate','same','corr');

        Ixx = Ixx(xG,yG,:);
        Ixy = Ixy(xG,yG,:);
        Iyy = Iyy(xG,yG,:);
        Ixt = Ixt(xG,yG,:);
        Iyt = Iyt(xG,yG,:);

        motion_update_normalized=getFlow2D_withPenalty_v3(Ixx,Ixy,Iyy,Ixt,Iyt,smoothPenaltySum,neiSum);
        %% the control points can't move far away
        motion_update_dist=sqrt(sum(motion_update_normalized.^2,4));
        motion_update_dist=max(motion_update_dist./movRange,1);
        motion_update=motion_update_normalized./motion_update_dist;
        
        %% get current motion of control point
        motion_current_CP = motion_current(xG,yG,:,:)+motion_update;
        %% get all pixels' the motion based on control points' motion
        x_new = (x_ind-r-1)/(2*r+1)+1;
        x_new = min(max(x_new,1),size(motion_current_CP,1));
        y_new = (y_ind-r-1)/(2*r+1)+1;
        y_new = min(max(y_new,1),size(motion_current_CP,2));
        z_new = z_ind;
        for dirNum=1:2
            temp_phi=gather(motion_current_CP(:,:,:,dirNum));
            motion_current(:,:,:,dirNum)= gpuArray(reshape(interp3(temp_phi,y_new,x_new,z_new),[ x y z]));  
        end
    end

end

motion_current = gather(motion_current);

end