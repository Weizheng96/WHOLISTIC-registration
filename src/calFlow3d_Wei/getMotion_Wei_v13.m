function motion_current=getMotion_Wei_v13(dat_mov,dat_ref,smoothPenalty_raw)
%% v13: rewrite the function of v12, make it clean

%% parameters need to adjust
layer_num=0;              % pyramid layer num
iterNum=40;
r=5;

%% for test
tempz=11;

%% parameters don't need to adjust
zRatio_raw=27;
movRange=[r r 0.5];
SZ=size(dat_mov);

%% multi-scale loop
for layer = layer_num:-1:0

    %% dowmsample for current scale
    smoothPenalty=smoothPenalty_raw*2^layer;
    data1 = gpuArray(imresize3(dat_mov, [round(SZ(1:2)/2^layer) SZ(3)]));
    data2 = gpuArray(imresize3(dat_ref, [round(SZ(1:2)/2^layer) SZ(3)]));
    [x,y,z] = size(data1);
    
    %% initilize the motion of each layer
    if layer == layer_num
        motion_current = gpuArray(zeros(x,y,z,3));
    else
        motion_current_temp=gather(motion_current);
        motion_current=zeros(x,y,z,3);
        motion_current(:,:,:,1) = imresize3(motion_current_temp(:,:,:,1), [x,y,z],"linear")*2;
        motion_current(:,:,:,2) = imresize3(motion_current_temp(:,:,:,2), [x,y,z],"linear")*2;
        motion_current(:,:,:,3) = imresize3(motion_current_temp(:,:,:,3), [x,y,z],"linear");
        motion_current=gpuArray(motion_current);
    end
    
    [x_ind,y_ind,z_ind] = ind2sub(size(data1),1:x*y*z);

    %% for test
    temp1=zeros(x,y,iterNum);temp2=zeros(x,y,iterNum);
    temp3=zeros(x,y,iterNum);temp4=zeros(x,y,iterNum);
    temp5=zeros(x,y,iterNum);temp6=zeros(x,y,iterNum);
    errorHistory=zeros(iterNum,1);

    %% update motion loop
    fprintf("\nDownsample:"+layer+"\n");
    for iter = 1:iterNum
        %% get corrected data
        data1_tran=correctMotion_Wei_v2(data1,motion_current);
       
        %% get spatial gradient
        [Ix,Iy,Iz]=getSpatialGradient_Wei(data1_tran);
       
        %% get temporal difference
        It = data1_tran-data2;
        It = imfilter(It,ones(3)/9,'replicate','same','corr');
    
        %% get motion update of control points
        AverageFilter=ones(r*2+1);
        xG=r+1:2*r+1:x;yG=r+1:2*r+1:y;zG=1:z;
        stepFactor=1;

        Ixx = imfilter(Ix.^2 ,AverageFilter,'replicate','same','corr');
        Ixy = imfilter(Ix.*Iy,AverageFilter,'replicate','same','corr');
        Ixz = imfilter(Ix.*Iz,AverageFilter,'replicate','same','corr');
        Iyy = imfilter(Iy.^2 ,AverageFilter,'replicate','same','corr');
        Iyz = imfilter(Iy.*Iz,AverageFilter,'replicate','same','corr');
        Izz = imfilter(Iz.^2 ,AverageFilter,'replicate','same','corr');
        Ixt = imfilter(Ix.*It,AverageFilter,'replicate','same','corr');
        Iyt = imfilter(Iy.*It,AverageFilter,'replicate','same','corr');
        Izt = imfilter(Iz.*It,AverageFilter,'replicate','same','corr');

        Ixx = Ixx(xG,yG,zG);
        Ixy = Ixy(xG,yG,zG);
        Ixz = Ixz(xG,yG,zG);
        Iyy = Iyy(xG,yG,zG);
        Iyz = Iyz(xG,yG,zG);
        Izz = Izz(xG,yG,zG);
        Ixt = Ixt(xG,yG,zG);
        Iyt = Iyt(xG,yG,zG);
        Izt = Izt(xG,yG,zG);

        smoothPenaltySum=smoothPenalty*stepFactor*sum(AverageFilter,'all');

        neiSum=smoothPenalty*stepFactor*getNeiSum2(motion_current,r);
        neiSum=neiSum(xG,yG,zG,:);

        zRatio=zRatio_raw/2^layer;
    
        phi_gradient=getFlow3_withPenalty3(Ixx,Ixy,Ixz,Iyy,Iyz,Izz,Ixt,Iyt,Izt,smoothPenaltySum,neiSum,zRatio);
        
        %% the control points can't move out of the corresponding patch
        fprintf("gradient:\t");
        for dirNum=1:3
            phi_gradient(:,:,:,dirNum)= min( movRange(dirNum),phi_gradient(:,:,:,dirNum));
            phi_gradient(:,:,:,dirNum)= max(-movRange(dirNum),phi_gradient(:,:,:,dirNum));
            fprintf("\t"+gather(std(phi_gradient(:,:,:,dirNum),[],'all')))
        end
        fprintf("\n");
        %% the trasnfer the motion update from current axis to original axis (not in this version)

        %% get all pixels' the motion update based on control points' motion update
        x_new = (x_ind-r-1)/(2*r+1)+1;
        x_new = min(max(x_new,1),size(phi_gradient,1));
        y_new = (y_ind-r-1)/(2*r+1)+1;
        y_new = min(max(y_new,1),size(phi_gradient,2));
        z_new = z_ind;
        phi_gradient_temp=phi_gradient;
        phi_gradient=motion_current;
        for dirNum=1:3
            temp_phi=gather(phi_gradient_temp(:,:,:,dirNum));
            phi_gradient(:,:,:,dirNum)= gpuArray(reshape(interp3(temp_phi,y_new,x_new,z_new),[ x y z]));  
        end
        %% add the motion update to current motion
        motion_current = motion_current + phi_gradient;

        %% calculate error (make it slow)
        data1_corrected=gather(correctMotion_Wei_v2(data1,motion_current));
        diffError=gather(mean((data2-data1_corrected).^2,'all','omitnan'));
        penaltyRaw=((r*2+1)^2-1)*motion_current-getNeiSum2(motion_current,r);
        penaltyRaw(:,:,:,3)=penaltyRaw(:,:,:,3)*zRatio;
        penaltyCorrected=sum(penaltyRaw.^2,4)*smoothPenalty;
        penaltyError=gather(mean(penaltyCorrected,'all'));
        fprintf("Downsample:"+layer+"\tIter:"+iter+"\tstep:\t"+stepFactor+"\tError:\t"+(diffError+penaltyError)+"\tDiff:\t"+diffError+"\n");

        temp1(:,:,iter)=data1_tran(:,:,tempz);
        temp2(:,:,iter)=phi_gradient(:,:,tempz,1);
%         temp3(:,:,iter)=Ixt(:,:,tempz)./Ixx(:,:,tempz);
%         temp4(:,:,iter)=It(:,:,tempz);
        temp5(:,:,iter)=data1_corrected(:,:,tempz);
        temp6(:,:,iter)=motion_current(:,:,tempz,1);
        errorHistory(iter)=diffError;


    end

end

motion_current = gather(motion_current);

end