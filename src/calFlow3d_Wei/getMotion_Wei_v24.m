function [motion_current,currentError]=getMotion_Wei_v24(dat_mov,dat_ref,smoothPenalty,option)
%% v24: based on v23d1, + better mask
dat_mov=single(dat_mov);
dat_ref=single(dat_ref);
%% parameters need to adjust
layer_num=option.larer;              % pyramid layer num
iterNum=option.iter;
r=option.r;
zRatio_raw=option.zRatio;

%% parameters don't need to adjust
SZ=size(dat_mov);
movRange=5;
%% multi-scale loop
for layer = layer_num:-1:0

    %% dowmsample for current scale
    data1 = gpuArray(imresize3(dat_mov, [round(SZ/2^layer)]));
    data2 = gpuArray(imresize3(dat_ref, [round(SZ/2^layer)]));
    [x,y,z] = size(data1);
    zRatio=zRatio_raw;
    
    %% initilize the motion of each layer
    if layer == layer_num
        if isfield(option,'motion') && ~isempty(option.motion)
            motion_current = gpuArray(zeros(x,y,z,3,"single"));
            motion_current(:,:,:,1)=imresize3(option.motion(:,:,:,1),[x,y,z])/(SZ(1)/x);
            motion_current(:,:,:,2)=imresize3(option.motion(:,:,:,2),[x,y,z])/(SZ(2)/y);
            motion_current(:,:,:,3)=imresize3(option.motion(:,:,:,3),[x,y,z])/(SZ(3)/z);
        else
            motion_current = gpuArray(zeros(x,y,z,3,"single"));
        end
    else
        motion_current_temp=gather(motion_current);
        motion_current=zeros(x,y,z,3,"single");
        motion_current(:,:,:,1) = imresize3(motion_current_temp(:,:,:,1), [x,y,z],"linear")*2;
        motion_current(:,:,:,2) = imresize3(motion_current_temp(:,:,:,2), [x,y,z],"linear")*2;
        motion_current(:,:,:,3) = imresize3(motion_current_temp(:,:,:,3), [x,y,z],"linear")*2;
        motion_current=gpuArray(motion_current);
    end
    
    [x_ind,y_ind,z_ind] = ind2sub(size(data1),1:x*y*z);
    %% initialize mask
    mask_ref=imresize3(option.mask_ref,[x,y,z])>0;
    mask_mov=imresize3(single(option.mask_mov),[x,y,z]);
    mask_pad=imresize3(single(option.mask_movPad),[x,y,z]);
    %% initial old error
    oldError=inf(3,1);
    %% get patch
    rz=round(r/zRatio);
    xG=r+1:2*r+1:x;yG=r+1:2*r+1:y;zG=1:2*rz+1:z;
    %% penalty parameters
    patchConnectNum=(r*2+1)^2*(rz*2+1);
    smoothPenaltySum=smoothPenalty*patchConnectNum;
    %% update motion loop
%     fprintf("\nDownsample:"+layer+"\n");
    for iter = 1:iterNum
        %% get corrected data
%         data1_tran=correctMotion_Wei_v2(data1,motion_current);  
        mask_mov_current=correctMotion_Wei_v2(mask_mov,motion_current)>0; 
        mask_pad_current=correctMotion_Wei_v2(mask_pad,motion_current)>=1; 
        mask= mask_mov_current|mask_ref|mask_pad_current;
        %% get temporal difference
        It = data2-correctMotion_Wei_v2(data1,motion_current);
        It = imfilter(It,ones(3)/9,'replicate','same','corr');
        It(mask)=0;
        %% get neighbor motion difference
        neiDiff=getNeiDiff_v2(motion_current(xG,yG,zG,:),1,1);
        neiDiff(:,:,:,3)=neiDiff(:,:,:,3)*zRatio;
        
        %% calculate error and decide to stop or not
        [diffError,penaltyError]=calError_v2(It,neiDiff,smoothPenaltySum);
        currentError=diffError+penaltyError;
%         fprintf("Downsample:"+layer+"\tIter:"+iter+"\tError:\t"+currentError+"\tDiff:\t"+diffError+"\n");

        if iter == iterNum || sum(oldError<=currentError)>1
%             disp("next layer");
            break;
        else
%             disp(layer+":"+iter+":"+currentError);
            oldError(1:end-1)=oldError(2:end);
            oldError(end)=currentError;
        end
        %% get motion update of control points
        [Ix,Iy,Iz]=getSpatialGradientInOrg_Wei(data1,motion_current);
        Ix(mask)=0;Iy(mask)=0;Iz(mask)=0;

        Iz=Iz./zRatio;

        AverageFilter=ones(r*2+1,r*2+1,rz*2+1);

        Itemp = imfilter(Ix.^2 ,AverageFilter,'replicate','same','corr');
        Ixx = Itemp(xG,yG,zG);
        Itemp = imfilter(Ix.*Iy,AverageFilter,'replicate','same','corr');
        Ixy = Itemp(xG,yG,zG);
        Itemp = imfilter(Ix.*Iz,AverageFilter,'replicate','same','corr');
        Ixz = Itemp(xG,yG,zG);
        Itemp = imfilter(Iy.^2 ,AverageFilter,'replicate','same','corr');
        Iyy = Itemp(xG,yG,zG);
        Itemp = imfilter(Iy.*Iz,AverageFilter,'replicate','same','corr');
        Iyz = Itemp(xG,yG,zG);
        Itemp = imfilter(Iz.^2 ,AverageFilter,'replicate','same','corr');
        Izz = Itemp(xG,yG,zG);
        Itemp = imfilter(Ix.*It,AverageFilter,'replicate','same','corr');
        Ixt = Itemp(xG,yG,zG);
        Itemp = imfilter(Iy.*It,AverageFilter,'replicate','same','corr');
        Iyt = Itemp(xG,yG,zG);
        Itemp = imfilter(Iz.*It,AverageFilter,'replicate','same','corr');
        Izt = Itemp(xG,yG,zG);

        motion_update_normalized=getFlow3_withPenalty6(Ixx,Ixy,Ixz,Iyy,Iyz,Izz,Ixt,Iyt,Izt,smoothPenaltySum,smoothPenaltySum*neiDiff);
        %% the control points can't move far away
        motion_update_dist=sqrt(sum(motion_update_normalized.^2,4));
        motion_update_dist=max(motion_update_dist./movRange,1);
        motion_update_normalized=motion_update_normalized./motion_update_dist;
        
        %% get unnomalized motion update
        motion_update=motion_update_normalized;
        motion_update(:,:,:,3)=motion_update(:,:,:,3)./zRatio;
        %% get current motion of control point
        motion_current_CP = motion_current(xG,yG,zG,:)+motion_update;
        %% median filter for motion
        for dirNum=1:3
            for zCnt=1:size(motion_current,3)
                motion_current(:,:,zCnt,dirNum)=medfilt2(motion_current(:,:,zCnt,dirNum));
            end
        end
        %% get all pixels' the motion based on control points' motion
        x_new = (x_ind-r-1)/(2*r+1)+1;
        x_new = min(max(x_new,1),size(motion_current_CP,1));
        y_new = (y_ind-r-1)/(2*r+1)+1;
        y_new = min(max(y_new,1),size(motion_current_CP,2));
        z_new = (z_ind-r-1)/(2*rz+1)+1;
        z_new = min(max(z_new,1),size(motion_current_CP,3));

        for dirNum=1:3
            temp_phi=gather(motion_current_CP(:,:,:,dirNum));
            motion_current(:,:,:,dirNum)= gpuArray(reshape(interp3(temp_phi,y_new,x_new,z_new),[ x y z]));  
        end
    end

end

motion_current = gather(motion_current);

end