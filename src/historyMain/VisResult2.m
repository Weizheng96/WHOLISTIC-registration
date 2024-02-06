% figure;
subplot(1,3,1);
imshow(data2(:,:,tempz));
title("reference image")
subplot(1,3,2);
imshow(data1(:,:,tempz))
title("Iter= "+0);
subplot(1,3,3);
hold off;
plot(1:iterNum,errorHistory)
xlabel("iteration #"); ylabel("MSE");title("error history");
hold on;
scatter(1:iterNum,errorHistory,'red')
set(gca,'YScale','log')
ylim([1e-8 1e-2]);
%%
for i=1:iterNum-1
    subplot(1,3,2);
    imshow(temp1(:,:,i))
    title("Iter= "+i);
    subplot(1,3,3);
    scatter(i,errorHistory(i),'red','filled')
    pause(0.1)
end
%% %%
figure
im=data1_corrected(:,:,tempz);
imshow(im);
[Y,X] = meshgrid(yG,xG);
U = gather(motion_current(xG,yG,tempz,1));
V = gather(motion_current(xG,yG,tempz,2));
hold on;
quiver(Y,X,V,U,0)

%% %%
[Y,X] = meshgrid(yG,xG);
U = gather(motion_current(xG,yG,tempz,1));
V = gather(motion_current(xG,yG,tempz,2));
Vnew=V+Y;Unew=U+X;

figure
im=data1_corrected(:,:,tempz);
imshow(im);
hold on;
for i=1:size(Vnew,1)
    plot(Vnew(i,:),Unew(i,:),'r')
end
for iy=1:size(Vnew,2)
    plot(Vnew(:,iy),Unew(:,iy),'g')
end
%% %%
figure;
subplot(1,3,1);
imshow(data2(:,:,tempz));
title("reference image")
subplot(1,3,2);
imshow(data1(:,:,tempz))
title("Iter= "+0);
subplot(1,3,3);
hold off;
plot(1:iterNum,errorHistory,'red')
hold on;
xlabel("iteration #"); ylabel("MSE");title("error history");
% plot(1:iterNum,intErrorHistory,'blue')
scatter(1:iterNum,errorHistory,'red')
% scatter(1:iterNum,intErrorHistory,'blue')
% set(gca,'YScale','log')
% ylim([0 1e-2]);
%%
subplot(1,3,3);
hold off;
plot(1:iterNum,errorHistory,'red')
hold on;
xlabel("iteration #"); ylabel("MSE");title("error history");
[Y,X] = meshgrid(yG,xG);
for i=2:iterNum
    subplot(1,3,2);
    hold off;
    U = gather(temp3(xG,yG,i));
    V = gather(temp4(xG,yG,i));
    Vnew=V+Y;Unew=U+X;

    imshow(temp1(:,:,i-1))
    subplot(1,3,1);
    hold off;
    imshow(data2(:,:,tempz));
    hold on;
    for ix=1:size(Vnew,1)
        plot(Vnew(ix,:),Unew(ix,:),'r')
    end
    for iy=1:size(Vnew,2)
        plot(Vnew(:,iy),Unew(:,iy),'g')
    end

    title("Iter= "+i);
    subplot(1,3,3);
    scatter(i,errorHistory(i),'red','filled')
    pause(0.5)
end
%% %%
figure;
subplot(1,3,1);
% imshow(data2(:,:,tempz));
title("reference image")
subplot(1,3,2);
imshow(data1(:,:,tempz))
title("Iter= "+0);
subplot(1,3,3);
hold off;
plot(1:iterNum,errorHistory,'red')
hold on;
xlabel("iteration #"); ylabel("MSE");title("error history");
% plot(1:iterNum,intErrorHistory,'blue')
scatter(1:iterNum,errorHistory,'red')
% scatter(1:iterNum,intErrorHistory,'blue')
% set(gca,'YScale','log')
% ylim([0 1e-2]);
%%
subplot(1,3,3);
hold off;
plot(1:iterNum,errorHistory,'red')
hold on;
xlabel("iteration #"); ylabel("MSE");title("error history");
[Y,X] = meshgrid(yG,xG);
for i=2:iterNum
    subplot(1,3,2);
    hold off;
    U = gather(temp3(xG,yG,i));
    V = gather(temp4(xG,yG,i));
    Vnew=V+Y;Unew=U+X;

    Z= gather(temp6(xG,yG,i));

    imshow(temp1(:,:,i-1))
    subplot(1,3,1);
    cla();
    for ix=1:size(Vnew,1)
        x=Vnew(ix,:);y=Unew(ix,:);%z=zeros(size(x));
        z=Z(ix,:);
        col=Z(ix,:);
        surface([x;x],[y;y],[z;z],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',2);
    end
    for iy=1:size(Vnew,2)
        x=Vnew(:,iy)';y=Unew(:,iy)';%z=zeros(size(x));
        z=Z(:,iy)';
        col=Z(:,iy)';
        surface([x;x],[y;y],[z;z],[col;col],...
        'facecol','no',...
        'edgecol','interp',...
        'linew',2);
    end

    title("Iter= "+i);
    subplot(1,3,3);
    scatter(i,errorHistory(i),'red','filled')
    pause(0.1)
end