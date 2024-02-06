figure
imshow(data1_corrected(:,:,4)/400)

phi_current(:,:,:)

im=randn(20,10);
imagesc(im);
[Y,X] = meshgrid(0:10,0:20);
U = 0.25*ones(size(X));
V = 1*ones(size(Y));
hold on;
quiver(Y,X,V,U,0)

%%
% tempz=4;
figure;
im=data1_corrected(:,:,tempz)/400;
imshow(im);
[Y,X] = meshgrid(yG,xG);
U = gather(motion_current(xG,yG,tempz,1));
V = gather(motion_current(xG,yG,tempz,2));
hold on;
quiver(Y,X,V,U,0)
%%
figure;
stepQuiver=1;
im=data1_corrected(:,:,tempz);
imshow(im);
[Y,X] = meshgrid(1:stepQuiver:size(im,2),1:stepQuiver:size(im,1));
U = gather(phi_current(1:stepQuiver:end,1:stepQuiver:end,tempz,1));
V = gather(phi_current(1:stepQuiver:end,1:stepQuiver:end,tempz,2));
hold on;
quiver(Y,X,V,U,0)
%%
tempz=4;
implay(cat(3,data2(:,:,tempz),data1_corrected(:,:,tempz))/400)
%%
implay((cat(3,data2(:,:,4),data1(:,:,4),temp1)-59)/(401-59))
%%
implay(cat(3,data2(:,:,tempz),data1(:,:,tempz),temp1))

implay(cat(2,data2(:,:,tempz).*ones(1,1,size(temp1,3)),temp1,-temp2/100,temp2/100,-temp4/0.1,temp4/0.1,-temp6/50));
%%
implay(cat(2,temp1/400,temp2/10000,temp3/100));

tempz=4;
implay(cat(2,data2(:,:,tempz).*ones(1,1,size(temp1,3))/400,temp1/400,-temp2/100,temp2/100,-temp3/100,temp3/100,-temp6/100,temp6/100));

ttemp=(It(:,:,4)./Ix(:,:,4));
histogram(temp3)

%%
plot(squeeze(temp6(50,5,:)))
hold on;
plot(squeeze(temp2(50,5,:)))
plot(squeeze(temp3(50,5,:)))
legend("all","step","raw step")
%%
figure;
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
ylim([0 1e-2]);
for i=1:iterNum
    subplot(1,3,2);
    imshow(temp5(:,:,i))
    title("Iter= "+i);
    subplot(1,3,3);
    scatter(i,errorHistory(i),'red','filled')
    pause(0.1)
end
%%
%%
% figure;
subplot(1,3,1);
imshow(data2(:,:,tempz)/400);
title("reference image")
subplot(1,3,2);
imshow(data1(:,:,tempz)/400)
title("Iter= "+0);
subplot(1,3,3);
hold off;
plot(1:iterNum,errorHistory)
xlabel("iteration #"); ylabel("MSE");title("error history");
hold on;
scatter(1:iterNum,errorHistory,'red')
% set(gca,'YScale','log')
% ylim([0 1e-1]);
for i=1:iterNum
    subplot(1,3,2);
    imshow(temp5(:,:,i)/400)
    title("Iter= "+i);
    subplot(1,3,3);
    scatter(i,errorHistory(i),'red','filled')
    pause(1)
end
%%
implay(sqrt(temp3)/patchConnectNum/5)
implay(temp4/100+0.5)
implay((temp1-100)/200)

implay((gather(data2(:,:,tempz)-temp1))/100+0.5)

implay(temp6/100+0.5)
