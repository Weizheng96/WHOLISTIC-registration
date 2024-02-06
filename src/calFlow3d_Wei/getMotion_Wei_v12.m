function phi_current=getMotion_Wei_v12(dat_mov,dat_ref,smoothPenalty_raw)
%% v12: patch wise

SZ=size(dat_mov);
layer_num = 0;              % pyramid layer num
pad_size = [100 100 3];  
step = 1;     % for calculate gradient
iterNum=40;
zRatio_raw=27;
r=5;
movRange=[1 1 1/zRatio_raw]*5;

tempz=11;


for layer = layer_num:-1:0

    smoothPenalty=smoothPenalty_raw*2^layer;

    data1 = imresize3(dat_mov, [round(SZ(1:2)/2^layer) SZ(3)]);
    data2 = imresize3(dat_ref, [round(SZ(1:2)/2^layer) SZ(3)]);

    [x,y,z] = size(data1);

    % pad image
    data1_pad = padarray(data1,pad_size,'replicate');
    gt2 = data2;
    
    % initilize the transform of each layer
    if layer == layer_num
        phi_current = gpuArray(zeros(x,y,z,3));
    else
        phi_current_temp=gather(phi_current);
        phi_current=zeros(x,y,z,3);
        phi_current(:,:,:,1) = imresize3(phi_current_temp(:,:,:,1), [x,y,z],"linear")*2;
        phi_current(:,:,:,2) = imresize3(phi_current_temp(:,:,:,2), [x,y,z],"linear")*2;
        phi_current(:,:,:,3) = imresize3(phi_current_temp(:,:,:,3), [x,y,z],"linear");
        phi_current=gpuArray(phi_current);
    end
    
    [x_ind,y_ind,z_ind] = ind2sub(size(data1),1:x*y*z);
    
    fprintf("\nDownsample:"+layer+"\n");
%     temp1=zeros(x,y,iterNum);temp2=zeros(x,y,iterNum);
%     temp3=zeros(x,y,iterNum);temp4=zeros(x,y,iterNum);
%     temp5=zeros(x,y,iterNum);temp6=zeros(x,y,iterNum);
%     errorHistory=zeros(iterNum,1);

%     oldPenaltyError=inf;
    for iter = 1:iterNum
        phi_previous = phi_current;
        x_bias = reshape(phi_previous(:,:,:,1),[1 x*y*z]);
        y_bias = reshape(phi_previous(:,:,:,2),[1 x*y*z]);
        z_bias = reshape(phi_previous(:,:,:,3),[1 x*y*z]);
       
        % get tranformed data
        x_new = x_ind + x_bias;
        y_new = y_ind + y_bias;
        z_new = z_ind + z_bias;
        data1_tran = interp3(data1_pad,y_new+pad_size(2),x_new+pad_size(1),z_new+pad_size(3));
        data1_tran = reshape(data1_tran, [x y z]);
       
        temp_diff1 = data1_tran(2,:,:) - data1_tran(1,:,:);
        temp_diff2 = (data1_tran(3:end,:,:) - data1_tran(1:end-2,:,:))/2;
        temp_diff3 = data1_tran(end,:,:) - data1_tran(end-1,:,:);
        Ix = cat(1,temp_diff1,temp_diff2,temp_diff3);
    
        temp_diff1 = data1_tran(:,2,:) - data1_tran(:,1,:);
        temp_diff2 = (data1_tran(:,3:end,:) - data1_tran(:,1:end-2,:))/2;
        temp_diff3 = data1_tran(:,end,:) - data1_tran(:,end-1,:);
        Iy = cat(2,temp_diff1,temp_diff2,temp_diff3);
    
        temp_diff1 = data1_tran(:,:,2) - data1_tran(:,:,1);
        temp_diff2 = (data1_tran(:,:,3:end) - data1_tran(:,:,1:end-2))/2;
        temp_diff3 = data1_tran(:,:,end) - data1_tran(:,:,end-1);
        Iz = cat(3,temp_diff1,temp_diff2,temp_diff3);
       
    
        % get gradient and hessian matrix
        It = data1_tran-gt2;
        It = imfilter(It,ones(3)/9,'replicate','same','corr');
    
        
        AverageFilter=ones(r*2+1);
        Ixx = imfilter(Ix.^2,AverageFilter,'replicate','same','corr');
        Ixy = imfilter(Ix.*Iy,AverageFilter,'replicate','same','corr');
        Ixz = imfilter(Ix.*Iz,AverageFilter,'replicate','same','corr');
        Iyy = imfilter(Iy.^2,AverageFilter,'replicate','same','corr');
        Iyz = imfilter(Iy.*Iz,AverageFilter,'replicate','same','corr');
        Izz = imfilter(Iz.^2,AverageFilter,'replicate','same','corr');
        Ixt = imfilter(Ix.*It,AverageFilter,'replicate','same','corr');
        Iyt = imfilter(Iy.*It,AverageFilter,'replicate','same','corr');
        Izt = imfilter(Iz.*It,AverageFilter,'replicate','same','corr');
 

        stepFactor=1;%min((iter-1)/3,1);
        neiSum=smoothPenalty*stepFactor*getNeiSum2(phi_current,r);
        smoothPenaltySum=smoothPenalty*stepFactor*sum(AverageFilter,'all');
    
        xG=r+1:2*r+1:x;yG=r+1:2*r+1:y;zG=1:z;
        xGL=length(xG);yGL=length(yG);
        zRatio=zRatio_raw/2^layer;
        phi_gradient=getFlow3_withPenalty3(...
            Ixx(xG,yG,zG),...
            Ixy(xG,yG,zG),...
            Ixz(xG,yG,zG),...
            Iyy(xG,yG,zG),...
            Iyz(xG,yG,zG),...
            Izz(xG,yG,zG),...
            Ixt(xG,yG,zG),...
            Iyt(xG,yG,zG),...
            Izt(xG,yG,zG),...
            smoothPenaltySum,...
            neiSum(xG,yG,zG,:),...
            zRatio);
        % keep conformal
%         phi_current_temp=phi_current(xG,yG,zG,:);
%         movRange_pos=zeros(size(phi_gradient));
%         movRange_neg=movRange_pos;
%         pos_diff=max((phi_current_temp(2:end,:,:,1)-phi_current_temp(1:end-1,:,:,1)+2*r+1)/2-r/10,0);
%         movRange_pos(:,:,:,1)=cat(1,pos_diff,zeros(1,yGL,z));
%         movRange_neg(:,:,:,1)=cat(1,zeros(1,yGL,z),-pos_diff);
%         pos_diff=max((phi_current_temp(:,2:end,:,1)-phi_current_temp(:,1:end-1,:,1)+2*r+1)/2-r/10,0);
%         movRange_pos(:,:,:,2)=cat(2,pos_diff,zeros(xGL,1,z));
%         movRange_neg(:,:,:,2)=cat(2,zeros(xGL,1,z),-pos_diff);
%         pos_diff=max((phi_current_temp(:,:,2:end,1)-phi_current_temp(:,:,1:end-1,1)+2*r+1)/2-r/10,0).*0;
%         movRange_pos(:,:,:,3)=cat(3,pos_diff,zeros(xGL,yGL,1));
%         movRange_neg(:,:,:,3)=cat(3,zeros(xGL,yGL,1),-pos_diff);
%         phi_gradient=min(phi_gradient,movRange_pos);
%         phi_gradient=max(phi_gradient,movRange_neg);
%         % get motion range
%         phi_gradient_temp=phi_gradient;
%         for dirNum=1:3
%             phi_gradient_temp(:,:,:,dirNum)=max(-movRange(dirNum),min(movRange(dirNum),phi_gradient(:,:,:,dirNum)));
%         end
%         % recorver whole motion
%         x_new = (x_ind-r-1)/(2*r+1)+1;x_new=min(max(x_new,1),size(phi_gradient_temp,1));
%         y_new = (y_ind-r-1)/(2*r+1)+1;y_new=min(max(y_new,1),size(phi_gradient_temp,2));
%         z_new = z_ind;
%         phi_gradient=phi_current;
%         for dirNum=1:3
%             phi_gradient(:,:,:,dirNum)= reshape(interp3(phi_gradient_temp(:,:,:,dirNum),y_new,x_new,z_new),[ x y z]);  
%         end
        
        %%
        fprintf("gradient:\t");
        for dirNum=1:3
            phi_gradient(:,:,:,dirNum)=max(-movRange(dirNum),min(movRange(dirNum),phi_gradient(:,:,:,dirNum)));
            fprintf("\t"+gather(std(phi_gradient(:,:,:,dirNum),[],'all')))
        end
        fprintf("\n");
        % recorver whole motion
        x_new = (x_ind-r-1)/(2*r+1)+1;x_new=min(max(x_new,1),size(phi_gradient,1));
        y_new = (y_ind-r-1)/(2*r+1)+1;y_new=min(max(y_new,1),size(phi_gradient,2));
        z_new = z_ind;
        phi_gradient_temp=phi_gradient;
        phi_gradient=phi_current;
        for dirNum=1:3
            temp_phi=gather(phi_gradient_temp(:,:,:,dirNum));
            phi_gradient(:,:,:,dirNum)= gpuArray(reshape(interp3(temp_phi,y_new,x_new,z_new),[ x y z]));  
        end
        %%
        phi_current = phi_current + phi_gradient;
        for dirNum=1:3
            phi_current(:,:,:,dirNum)=max(-pad_size(dirNum),min(pad_size(dirNum),phi_current(:,:,:,dirNum)));
        end

        %% calculate error (make it slow)
        data1_corrected=correctMotion_Wei(data1,phi_current);
        diffError=mean((data2-data1_corrected).^2,'all','omitnan');
        penaltyRaw=((r*2+1)^2-1)*phi_current-getNeiSum2(phi_current,r);
        penaltyRaw(:,:,:,3)=penaltyRaw(:,:,:,3)*zRatio;
        penaltyCorrected=sum(penaltyRaw.^2,4)*smoothPenalty;
        penaltyError=gather(mean(penaltyCorrected,'all'));

        fprintf("Downsample:"+layer+"\tIter:"+iter+"\tstep:\t"+stepFactor+"\tError:\t"+(diffError+penaltyError)+"\tDiff:\t"+diffError+"\n")

        temp1(:,:,iter)=data1_tran(:,:,tempz);
        temp2(:,:,iter)=phi_gradient(:,:,tempz,1);
        temp3(:,:,iter)=Ixt(:,:,tempz)./Ixx(:,:,tempz);
        temp4(:,:,iter)=It(:,:,tempz);
        temp5(:,:,iter)=data1_corrected(:,:,tempz);
        temp6(:,:,iter)=phi_current(:,:,tempz,1);
        errorHistory(iter)=diffError;

%         if oldPenaltyError>diffError || iter<5
%             oldPenaltyError=diffError;
%         else
%             phi_current=phi_previous;
%             break;
%         end

%         fprintf("Downsample:"+layer+"\tIter:"+iter+"\tstep:\t"+gather(std(phi_gradient(:,:,:,1:2),[],'all'))+"\n");
%         pause(1);


    end

end

phi_current = gather(phi_current);

end