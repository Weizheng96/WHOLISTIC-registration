dataPath="/work/Wei/Projects/WholeFishAnalyss/dat/dat_crop.mat";
load(dataPath,"dat_crop");

%%
dat=double(dat_crop);
maxIntensity=600;minIntensity=100;
dat_vis=(dat-minIntensity)/(maxIntensity-minIntensity);
dat_vis=min(max(dat_vis,0),1);
% dat_vis=dat_vis(1100:end-100,1000:end-500,:);
implay(dat_vis)


%%
% [H,W,T]=size(dat_vis);
% h = figure;
% for i=1:T-1
%     img1 = im2double(dat_vis(:,:,i)); % the images should be in double
%     img2 = im2double(dat_vis(:,:,i+1));
%     opflow = opticalFlow(img1, img2);
%     movegui(h);
%     hViewPanel = uipanel(h,'Position',[0 0 1 1],'Title','Plot of Optical Flow Vectors');
%     hPlot = axes(hViewPanel);
%     imshow(img1)
%     hold on
% %     plot(opflow,'DecimationFactor',[1 1]*20,'ScaleFactor',30,'Parent',hPlot,"red");
%     [X,Y] = meshgrid(1:20:W,1:20:H);
%     U=opflow.Vx(1:20:H,1:20:W);V=opflow.Vy(1:20:H,1:20:W);
%     quiver(X,Y,U,V,"red");
%     hold off
%     title(i)
%     pause(2);
% end

%%
opticFlow = opticalFlowHS;
% opticFlow.NoiseThreshold = 0.001;
% opticFlow.Smoothness = 0.001;
data0 = dat_vis;
[H,W,T] = size(data0);
[T1] = size(data0,3);
% T1 = 100;
flows = cell(T1,1);
for t = 1:T1
    flows{t} = estimateFlow(opticFlow,data0(:,:,t));
end
%%
h = figure('units','pixels','position',[0 0 1920 1080]);
%%
for t = 2:T1
    imshow(data0(:,:,t))
    hold on
%     hViewPanel.Title = ['Plot of Optical Flow Vectors, time point ',num2str(t)];
    if t>1
%         plot(flows{t},'DecimationFactor',[10 10],'ScaleFactor',200,'Parent',hPlot);
        plot(flows{t},'DecimationFactor',[5 5],'ScaleFactor',300);
    else
        
    end
    hold off
    title(num2str(t));
    pause(0.2)

end

%% check flow
close all;
Vx = zeros(H,W,T1,'single');
Vy = zeros(H,W,T1,'single');
for t = 2:T1
    Vx(:,:,t) = flows{t}.Vx;
    Vy(:,:,t) = flows{t}.Vy;
end
% clear flows;
% observe Vx and Vy
magnitude = sqrt(Vx.^2 + Vy.^2);
ov = zeros(2*H,W,T1);
ov(1:H,:,:) = magnitude/max(magnitude(:))*100;
ov(H+1:end,:,:) = data0(:,:,1:T1);
implay(double(ov));

%%
figure;
for t = 2:T1
    subplot(121);
    imshow(data0(:,:,t))
    hold on
%     hViewPanel.Title = ['Plot of Optical Flow Vectors, time point ',num2str(t)];
    if t>1
%         plot(flows{t},'DecimationFactor',[10 10],'ScaleFactor',200,'Parent',hPlot);
        plot(flows{t},'DecimationFactor',[5 5],'ScaleFactor',300);
    else
        
    end
    hold off
%     title(num2str(t));
    subplot(122);
    imshow(magnitude(:,:,t)/max(magnitude(:))*100)
    pause(0.2)

end
