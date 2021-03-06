function connHBhp

%% ssp+ica by time window

cd /media/yuval/win_disk/Data/connectomeDB/MEG
load Subs
fn='c,rfDC';
win0=round(2034.5*(0:0.1:0.6));
for subi=[1,3:10]
    cd /media/yuval/win_disk/Data/connectomeDB/MEG
    cd(num2str(Subs(subi)))
    cd unprocessed/MEG/3-Restin/4D/
    cfg=[];
    cfg.dataset=fn;
    cfg.demean='yes';
    cfg.bpfilter='yes';
    cfg.bpfreq=[1 40];
    cfg.channel={'MEG','-A2'};
    cfg.trl=[1,203450,0];
    data=ft_preprocessing(cfg);
    cfg.dataset=['hb5cat_',fn];
    datahb=ft_preprocessing(cfg);
    load comp
    Ncomp(subi)=length(compi);
    cfg=[];
    cfg.component=compi;
    datapca2=ft_rejectcomponent(cfg,comp);
%     cfg.component=compi(1);
%     datapca1=ft_rejectcomponent(cfg,comp);
    cfg=[];
    cfg.hpfilter='yes';
    cfg.hpfreq=25;
    cfg.demean='yes';
    datahp=ft_preprocessing(cfg,data);
    datahb=ft_preprocessing(cfg,datahb);
    datapca2=ft_preprocessing(cfg,datapca2);
    %datapca2=data.trial{1}-comp.topo(:,compi)*comp.trial{1}(compi,:);
    sRate=data.fsample;
    BL=[0.45 0.65];% or -0.5 to -0.3
    BLs=round(BL*data.fsample);
    Rs=[-203 203];
    load HBtimes
    HBtimes=HBtimes(2:find(HBtimes>98,1));
    for wini=1:length(win0)
        S=[];
        for HBi=1:length(HBtimes)
            beg=round(sRate*HBtimes(HBi)+win0(wini)-102);
            sto=round(sRate*HBtimes(HBi)+win0(wini)+102);
            S=[S,beg:sto];
        end
        rrhb=corr(datahp.trial{1}(:,S)');
        rrhb(logical(eye(length(rrhb))))=nan;
        posCorrRaw(subi,wini)=nanmean(nanmean(rrhb));
        rrhb=corr(datahb.trial{1}(:,S)');
        rrhb(logical(eye(length(rrhb))))=nan;
        posCorrHB(subi,wini)=nanmean(nanmean(rrhb));
        if wini==1
            [A]=princomp(data.trial{1}(:,S)');
            compg2=g2loop(A(:,1:40)'*data.trial{1},sRate);
            compii=find(compg2>median(compg2)*5);
            if length(compii)>1
                error('more than one comp')
            end
            if length(compii)==0
                [~,compii]=max(compg2);
            end
            dataclean=data.trial{1}-A(:,compii)*(A(:,compii)'*data.trial{1});
            data.trial{1}(:,:)=dataclean;
            dataclean=ft_preprocessing(cfg,data);
        end
         % recycling variables here to save space
        rrhb=corr(dataclean.trial{1}(:,S)');
        rrhb(logical(eye(length(rrhb))))=nan;
        posCorrSSP(subi,wini)=nanmean(nanmean(rrhb));
        
        rrhb=corr(datapca2.trial{1}(:,S)');
        rrhb(logical(eye(length(rrhb))))=nan;
        posCorrICA2(subi,wini)=nanmean(nanmean(rrhb));
%         rrhb=corr(datapca1.trial{1}(:,S)');
%         rrhb(logical(eye(length(rrhb))))=nan;
%         posCorrICA1(subi,wini)=nanmean(nanmean(rrhb));
        
    end
    clear data*
    disp(['XXXXXXXXXXX ',num2str(subi),' XXXXXXXXXXXXXX'])
end
Ncomp
cd /media/yuval/win_disk/Data/connectomeDB/MEG
save posCorrHP posCorr* Ncomp
posCorrHB(2,:)=[];
posCorrRaw(2,:)=[];
posCorrSSP(2,:)=[];
posCorrICA2(2,:)=[];
load HB100s
HB=mean(HBall);
HB=HB-HB(1);
time=-0.1:1/2034.5:0.65;

bars=[mean(posCorrSSP);mean(posCorrHB);mean(posCorrICA2);mean(posCorrRaw)];
figure;
plot(time,HB./max(HB).*max(mean(posCorrRaw(:,1))),'r')
hold on
bar(0:0.1:0.6,bars');
legend('timecourse','SSP','Template','ICA','Raw')

bars=[median(posCorrSSP./posCorrRaw);median(posCorrHB./posCorrRaw);median(posCorrICA2./posCorrRaw)]-1;
figure;
plot(time,HB./max(HB).*max(max(bars)),'r')
hold on
bar(0:0.1:0.6,bars')
legend('timecourse','SSP','Template','ICA')



bars=[mean(posCorrSSP(1:8,:));mean(posCorrHB(1:8,:));mean(posCorrICA2(1:8,:));mean(posCorrRaw(1:8,:))];
figure;
plot(time,HB./max(HB).*max(mean(posCorrRaw(1:8,1))),'r')
hold on
bar(0:0.1:0.6,bars');
legend('timecourse','SSP','Template','ICA','Raw')
lims=ylim;
bars=[posCorrSSP(9,:);posCorrHB(9,:);posCorrICA2(9,:);posCorrRaw(9,:)]
figure;
plot(time,HB./max(HB).*max(mean(posCorrRaw(1:8,1))),'r')
hold on
bar(0:0.1:0.6,bars');
legend('timecourse','SSP','Template','ICA','Raw')
ylim(lims);

% bars=[median(posCorrSSP./posCorrRaw);median(posCorrHB./posCorrRaw);median(posCorrICA2./posCorrRaw)]-1;
% figure;
% plot(time,HB./max(HB).*max(max(bars)),'r')
% hold on
% bar(0:0.1:0.6,bars')
% legend('timecourse','SSP','Template','ICA')