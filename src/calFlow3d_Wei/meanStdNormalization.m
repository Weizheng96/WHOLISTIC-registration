function dat_mov_normalized=meanStdNormalization(dat_mov,muRef,sigmaRef)

% muRef=mean(dat_ref,'all');sigmaRef=std(dat_ref,0,'all');
mu=mean(dat_mov,'all');sigma=std(dat_mov,0,'all');
sigmaRatio=sigmaRef/sigma;
dat_mov_normalized=dat_mov.*sigmaRatio+(muRef-mu*sigmaRatio);


end