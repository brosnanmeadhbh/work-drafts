%% b028 two foci connectivity
% Anterior (lesion) [8.5 2 5.5], Parietal [-1 4.5 8.5]

% make the VS
cd ~/Data/kurtosis/b028
cd SAM
[SAMHeader, ActIndex, ActWgts]=readWeights('Spikes,20-70Hz,Global.wts');

ind=voxIndex([8.5 2 5.5;-1 4.5 8.5],[-10 10 -9 9 0 15],0.5)
cd ../
fn='c,rfhp1.0Hz,ee';
hdr=ft_read_header(fn);
cfg=[];
cfg.dataset=fn;
cfg.trl=[1 hdr.nSamples 0];
cfg.bpfreq=[20 70];
cfg.bpfilter='yes';
cfg.channel='MEG';
data=ft_preprocessing(cfg);
vs=ActWgts(ind,:)*data.trial{1,1};
figure;plot(data.time{1,1},vs);
[c,lags]=xcorr(vs(1,:),vs(2,:),1000); % negative when first line is active before second line
figure;plot(lags,c)
[~,maxcor]=max(abs(c));
antBeforePar=round(1000*(-lags(maxcor)/hdr.Fs)); % lag in ms (15ms)
temp=zeros(1,68);
temp(end-6:end)=[1 2 3 4 5 6 7];
start=find(temp,1);
tempBlc = temp-mean(temp);
tmplt=tempBlc./sqrt(sum(tempBlc.*tempBlc));
[SNR1,SigX1,sigSign1]=fitTemp(vs(1,:),tmplt,start,0);
[SNR2,SigX2,sigSign2]=fitTemp(vs(2,:),tmplt,start,0);
figure;
plot(data.time{1,1},vs(1,:)./max(vs(1,:)));
hold on
plot(data.time{1,1},SNR1.*sigSign1./max(SNR1),'k');

[peaks1, Ipeaks1] = findPeaks(SNR1,3, round(678/4));
figure;
plot(vs')
hold on
plot(Ipeaks1,vs(1,Ipeaks1),'ro')

[peaks2, Ipeaks2] = findPeaks(SNR2,3, round(678/4));
events1=zeros(1,length(SNR1));
events2=events1;
events1(Ipeaks1)=1;
events2(Ipeaks2)=1;

smfc=33;
[c,lags]=xcorr(smooth(events1,smfc),smooth(events2,smfc),10000);
plot(lags,c);


smfc=678;
[c1,lags]=xcorr(smooth(events1,smfc),smooth(events1,smfc),10000);
c2=xcorr(smooth(events2,smfc),smooth(events2,smfc),10000);
c1_2=xcorr(smooth(events1,smfc),smooth(events2,smfc),10000);
figure;
plot(lags,c1);
hold on
plot(lags,c2,'k');plot(lags,c1_2,'r');
legend('Ant Ant','Post Post','Ant Post')


smfc=5;
[c,lags]=xcorr(smooth(abs(vs(1,:)),smfc),smooth(abs(vs(2,:)),smfc),10000);
plot(lags,c);



% Signal = (sum(vs.*tmplt))^2;
% Total = sum(data.*data);
% Error = Total - Signal;
% SNR=Signal/Error;
%% find events and baseline for freq analysis

cd /home/yuval/Copy/MEGdata/b272/2
fn='c,rfhp1.0Hz';
p=pdf4D(fn);
cleanCoefs = createCleanFile(p, fn,...
    'byLF',256 ,'Method','Global',...
    'byFFT',0,...
    'HeartBeat',0);
% cleanCoefs = createCleanFile(p, fn,'byLF',0,'byFFT',0,'HeartBeat',[]); %
% no good, spikes deleted

fn=['lf_',fn];
hdr=ft_read_header(fn);
cfg=[];
cfg.dataset=fn;
cfg.trl=[1 hdr.nSamples 0];
cfg.hpfreq=3;
cfg.hpfilter='yes';
cfg.channel='MEG';
data=ft_preprocessing(cfg);
avg=mean(data.trial{1,1});
avgabs=mean(abs(data.trial{1,1}));
plot(avgabs)
hold on
plot(avg,'r')
avgabs=avgabs-abs(avg);
plot(avgabs,'g')
[a,b]=findPeaks(avgabs,3,300);
figure;
plot(avgabs)
hold on
plot(b,a,'or')
troughs=smooth(-avgabs,1000);
[a1,b1]=findPeaks(troughs,0.5,1000);
a1=a1(2:length(a)+1);b1=b1(2:length(a)+1);
plot(b1,-a1,'ko')
cfg.trl=b'-509;
cfg.trl(:,2)=b'+509;
cfg.trl(:,3)=-509;
cfg.hpfilter='no';
epi=ft_preprocessing(cfg);
cfg.trl=b1'-509;
cfg.trl(:,2)=b1'+509;
cfg.trl(:,3)=-509;
bl=ft_preprocessing(cfg);

cfg=[];
cfg.method     =   'mtmfft';
cfg.keeptrials = 'no';
cfg.foi=3:200;
cfg.taper='dpss';
cfg.tapsmofrq=1;
frqEpi=ft_freqanalysis(cfg,epi);
frqBL=ft_freqanalysis(cfg,bl);
maxEpi=max(frqEpi.powspctrm);
maxBL=max(frqBL.powspctrm);
figure;
plot(frqEpi.freq,[maxBL;maxEpi])
legend('maxBL','maxEpi')
% frqNorm=frqEpi;
% frqNorm.powspctrm=frqEpi.powspctrm./(frqEpi.powspctrm-frqBL.powspctrm);
frqDif=frqEpi;
frqDif.powspctrm=frqEpi.powspctrm-frqBL.powspctrm;
cfg=[];
cfg.interactive='yes';
cfg.xlim=[56 56];
% figure;ft_topoplotER(cfg,frqNorm);
figure;ft_topoplotER(cfg,frqDif);
figure;
cfg=[];
for freqi=20:10:90
    subplot(2,4,(freqi-10)/10)
    cfg.xlim=[freqi freqi];
    cfg.comment='xlim';
    ft_topoplotER(cfg,frqDif);
end
    
cd /home/yuval/Copy/MEGdata/b272
!SAMcov -r 2 -d lf_c,rfhp1.0Hz -m Spikes -v
!SAMwts -r 2 -d lf_c,rfhp1.0Hz -m Spikes -c Global -v
!SAMepi -r 2 -d lf_c,rfhp1.0Hz -m Spikes -v

!SAMcov -r 2 -d lf_c,rfhp1.0Hz -m SpikesHGamma -v
!SAMwts -r 2 -d lf_c,rfhp1.0Hz -m SpikesHGamma -c Global -v
!SAMepi -r 2 -d lf_c,rfhp1.0Hz -m SpikesHGamma -v
%% old

% simaulated data to show g2 basics
figure1=kurFigSimulation;

cd /home/yuval/Data/kurtosis/b044
cfg=[];
cfg.dataset='c,rfhp1.0Hz,ee';
cfg.trialfun='trialfun_raw';
cfg1=ft_definetrial(cfg);
cfg1.channel='MEG';
cfg1.bpfilter='yes';
cfg1.bpfreq=[20 70];
data=ft_preprocessing(cfg1);
timeline=data.time{1,1};
vs=ActWgts*data.trial{1,1};
% vsP=zeros(size(vs));
% for vsi=1:10
%     vsP(vsi,:)=vs(vsi,:)+vsi*(10^-7);
% end
% plot(timeline,vsP)
% vsE1=vs(:,round(6.75*data.fsample):round(7.25*data.fsample));
% plot(vsE1')
% G2(vsE1)
% sc=repmat(max(abs(vsE1')),340,1)';
%  vsE1sc=vsE1./sc;
%  vsE1P=zeros(size(vsE1));
%  for vsi=1:10
%     vsE1P(vsi,:)=vsE1sc(vsi,:)+vsi;
%  end
%  plot(vsE1P')
 
 [SAMHeader, ActIndex, ActWgts]=readWeights('Global,20-70Hz,Global,ECD.wts');
 save('Global,20-70Hz,Global,ECD.mat','SAMHeader', 'ActIndex', 'ActWgts')
 xyz=[1.5 3 10];
 [ind,~]=voxIndex(xyz,100.*[...
    SAMHeader.XStart SAMHeader.XEnd ...
    SAMHeader.YStart SAMHeader.YEnd ...
    SAMHeader.ZStart SAMHeader.ZEnd],...
    100.*SAMHeader.StepSize,1);
vsPar=ActWgts(uint16(ind),:)*data.trial{1,1};
xyz=[8 2 6.5];
[ind,~]=voxIndex(xyz,100.*[...
    SAMHeader.XStart SAMHeader.XEnd ...
    SAMHeader.YStart SAMHeader.YEnd ...
    SAMHeader.ZStart SAMHeader.ZEnd],...
    100.*SAMHeader.StepSize,1);
vsFro=ActWgts(uint16(ind),:)*data.trial{1,1};
lastSamp=round(10*data.fsample);
vsFroSc=vsFro(1:lastSamp)/max(abs(vsFro(300:1000)));
vsParSc=vsPar(1:lastSamp)/max(abs(vsPar(300:1000)));
A22=data.trial{1,1}(1,1:lastSamp);
A22Sc=A22/max(abs(A22(300:1000)));
plot(timeline(1:lastSamp),vsParSc,'k')
hold on;plot(timeline(1:lastSamp),vsFroSc+3,'k')
plot(timeline(1:lastSamp),A22Sc+10,'k')
G2([vsParSc;vsFroSc])

load 'Global,20-70Hz,Global,ECD.mat'

load vsFro
plot(timeline,vsFro)
t10=nearest(timeline,10);
t20=nearest(timeline,20);
t60=nearest(timeline,60);
G2(vsFro(t10:t20))
G2(vsFro(t10:t60))

cd /home/yuval/Data/kurtosis/b093
cfg1=[];
cfg1.dataset='c,rfhp1.0Hz,ee';
cfg1.trl=round(678.17*[9.2 9.7 0;10.1 10.6 0;10.7 11.2 0]);
cfg1.channel='MEG';
%cfg1.bpfilter='yes';
%cfg1.bpfreq=[1 150];
data=ft_preprocessing(cfg1);
cfg=[];
cfg.method     =   'mtmfft';
cfg.keeptrials = 'yes';
cfg.foi=3:150;
cfg.taper='dpss';
cfg.tapsmofrq=2;
frq=ft_freqanalysis(cfg,data);
A113tr1=squeeze(frq.powspctrm(2,100,:)./frq.powspctrm(1,100,:));
figure;plot(frq.freq,A113tr1)
A113tr2=squeeze(frq.powspctrm(3,100,:)./frq.powspctrm(1,100,:));
hold on
plot(frq.freq,A113tr2,'r')
legend('first / baseline','second / baseline')
timeline=data.time{1,1};
plot(data.trial{1,1}(1,:))

A117tr1=squeeze(frq.powspctrm(2,100,:)./frq.powspctrm(1,190,:));
figure;plot(frq.freq,A117tr1)
A117tr2=squeeze(frq.powspctrm(3,100,:)./frq.powspctrm(1,190,:));
hold on
plot(frq.freq,A117tr2,'r')
legend('first / baseline','second / baseline')
timeline=data.time{1,1};
plot(data.trial{1,1}(1,:))
cfg=[];
cfg.interactive='yes';
figure;ft_topoplotER(cfg,frq);
frq2=frq;
frq2.powspctrm=frq.powspctrm(2,:,:)-frq.powspctrm(1,:,:);
figure;ft_topoplotER(cfg,frq2);

hdr=ft_read_header('c,rfhp1.0Hz,ee')
cfg1=[];
cfg1.dataset='c,rfhp1.0Hz,ee';
cfg1.trl=[1 hdr.nSamples 0];
cfg1.channel='MEG';
cfg1.bpfilter='yes';
cfg1.bpfreq=[16 80];
data=ft_preprocessing(cfg1);

%[SAMHeader, ActIndex, ActWgts]=readWeights('Spikes,16-80Hz,Global.wts');
% save('Spikes,16-80Hz,Global.mat','SAMHeader', 'ActIndex', 'ActWgts')
 load ('SAM/Spikes,16-80Hz,Global.mat')
xyz=[5 -3 9];
 [ind,~]=voxIndex(xyz,100.*[...
    SAMHeader.XStart SAMHeader.XEnd ...
    SAMHeader.YStart SAMHeader.YEnd ...
    SAMHeader.ZStart SAMHeader.ZEnd],...
    100.*SAMHeader.StepSize,1);

Rfro=ActWgts(ind,:)*data.trial{1,1};
timeline=data.time{1,1};
save Rfro Rfro timeline

A116=data.trial{1,1}(92,:);
A116=A116./max(abs(A116(1:1000)));
A117=data.trial{1,1}(190,:);
A117=A117./max(abs(A117(1:1000)));
A118=data.trial{1,1}(227,:);
A118=A118./max(abs(A118(1:1000)));
Rfro=Rfro./max(abs(Rfro(1:1000)));
sc=10;


xyz=[5 2.5 8.5];
 [ind,~]=voxIndex(xyz,100.*[...
    SAMHeader.XStart SAMHeader.XEnd ...
    SAMHeader.YStart SAMHeader.YEnd ...
    SAMHeader.ZStart SAMHeader.ZEnd],...
    100.*SAMHeader.StepSize,1);

Lfro=ActWgts(ind,:)*data.trial{1,1};
Lfro=Lfro./max(abs(Lfro(1:1000)));

figure;
plot(timeline,A116+sc,'k')
hold on
plot(timeline,A117+2*sc,'k')
plot(timeline,A118+3*sc,'k')
plot(timeline,Rfro)
plot(timeline,Lfro-sc)
legend('A116','A117','A118','Rfro','Lfro')




data.trial{1,1}(36,:)=(data.trial{1,1}(134,:)+data.trial{1,1}(174,:))./2;

cfg=[];

cfg.zlim=[-2e-12 2e-12];
%cfg.interactive='yes';
cfg.marker='off';
cfg.comment='no';


x=10.2157;
cfg.xlim=[x x];
figure;
ft_topoplotER(cfg,data);
title(num2str(cfg.xlim(1)))

x=10.2202;
cfg.xlim=[x x];
figure;
ft_topoplotER(cfg,data);
title(num2str(cfg.xlim(1)))


cfg1=[];
cfg1.dataset='c,rfhp1.0Hz,ee';
cfg1.trl=[5000 10000 5000];
cfg1.channel='MEG';
cfg1.bpfilter='yes';
cfg1.bpfreq=[3 80];
data=ft_preprocessing(cfg1);    
chi=[190 118 9];
MEG=zeros(1,length(data.time{1,1}));
sc=10;
for ci=1:3
    meg=data.trial{1,1}(chi(ci),:);
    meg=meg./max(abs(meg(1:1000)));
    MEG(ci,:)=meg(1,:)+ci*sc;
end
plot(data.time{1,1},MEG)


% status
cd /home/yuval/Data/kurtosis/b024
cfg1=[];
cfg1.dataset='hb_c,rfhp1.0Hz,ee';
cfg1.trl=[1 67817 0];
cfg1.channel='MEG';
cfg1.bpfilter='yes';
cfg1.bpfreq=[3 80];
data=ft_preprocessing(cfg1);

[SAMHeader, ActIndex, ActWgts]=readWeights('SAM/Global,20-70Hz,Global,ECD.wts');
save('SAM/Global,20-70Hz,Global,ECD.mat','SAMHeader', 'ActIndex', 'ActWgts')
xyz=[3 -4 8];
[ind,~]=voxIndex(xyz,100.*[...
    SAMHeader.XStart SAMHeader.XEnd ...
    SAMHeader.YStart SAMHeader.YEnd ...
    SAMHeader.ZStart SAMHeader.ZEnd],...
    100.*SAMHeader.StepSize,1);
vsR=ActWgts(uint16(ind),:)*data.trial{1,1};

vsR=vsR./1e-7;
A33=data.trial{1,1}(188,:);
A33=A33./1e-12;
plot(data.time{1,1},[A33+5;vsR])

for ti=1:9
    lat(ti)=2^(ti-4);
    samps=round(678.17*lat(ti));
    segBeg=1:round(samps/2):length(vsR);
    segBeg=segBeg(1:end-2);
    X=[];
    for segi=1:length(segBeg)
        X(segi,1:samps)=vsR(segBeg(segi):(segBeg(segi)+samps-1));
    end
    g=G2(X);
    maxG2(ti)=max(g);
    sumG2(ti)=sum(g(find(g>1)));
end
maxG2
meanG2

xyz=[0.5 3.5 10];
[indL,~]=voxIndex(xyz,100.*[...
    SAMHeader.XStart SAMHeader.XEnd ...
    SAMHeader.YStart SAMHeader.YEnd ...
    SAMHeader.ZStart SAMHeader.ZEnd],...
    100.*SAMHeader.StepSize,1);

xyz=[-2.5 -3 9];%[1.5 -2 10];
[indR,~]=voxIndex(xyz,100.*[...
    SAMHeader.XStart SAMHeader.XEnd ...
    SAMHeader.YStart SAMHeader.YEnd ...
    SAMHeader.ZStart SAMHeader.ZEnd],...
    100.*SAMHeader.StepSize,1);

vsR=ActWgts(uint16(indR),:)*data.trial{1,1};
vsL=ActWgts(uint16(indL),:)*data.trial{1,1};

for ti=1:9
    lat(ti)=2^(ti-4);
    samps=round(678.17*lat(ti));
    segBeg=1:round(samps/2):length(vsL);
    segBeg=segBeg(1:end-2);
    X=[];
    for segi=1:length(segBeg)
        X(segi,1:samps)=vsL(segBeg(segi):(segBeg(segi)+samps-1));
    end
    g=G2(X);
    maxG2L(ti)=max(g);
    sumG2L(ti)=sum(g(find(g>0)));
end



for ti=1:9
    lat(ti)=2^(ti-4);
    samps=round(678.17*lat(ti));
    segBeg=1:round(samps/2):length(vsR);
    segBeg=segBeg(1:end-2);
    X=[];
    for segi=1:length(segBeg)
        X(segi,1:samps)=vsR(segBeg(segi):(segBeg(segi)+samps-1));
    end
    g=G2(X);
    maxG2R(ti)=max(g);
    sumG2R(ti)=sum(g(find(g>0)));
end

maxG2L
sumG2L
maxG2R
sumG2R
vsR=vsR./1e-7;vsL=vsL./1e-7;
t=[2 6];s=round(678.17*t);
plot(data.time{1,1}(s(1):s(2)),[vsR(:,s(1):s(2))+1.5;vsL(:,s(1):s(2))],'k','LineWidth',2)
legend('R','L')

rnd=rand(1,length(vsR));
for ti=1:9
    lat(ti)=2^(ti-4);
    samps=round(678.17*lat(ti));
    segBeg=1:round(samps/2):length(rnd);
    segBeg=segBeg(1:end-2);
    X=[];
    for segi=1:length(segBeg)
        X(segi,1:samps)=rnd(segBeg(segi):(segBeg(segi)+samps-1));
    end
    g=G2(X);
    maxG2rnd(ti)=max(g);
    sumG2rnd(ti)=sum(g(find(g>0)));
end




% simulate rare spikes
rate=[1,2,4,8,16,32];
rate=round(rate*678.17);
vx=rand(1,67817);
vx=vx-mean(vx);
for ratei=1:6;
    vs=vx;
    for begSpike=1:rate(ratei):67817-rate(ratei);
        vs(begSpike:begSpike+32)=vx(begSpike:begSpike+32)+5*[[0:0.1:1.6],[1.5:-0.1:0]];
    end
    
    for ti=1:9
        lat(ti)=2^(ti-4);
        samps=round(678.17*lat(ti));
        segBeg=1:round(samps/2):length(vx);
        segBeg=segBeg(1:end-2);
        X=[];
        for segi=1:length(segBeg)
            X(segi,1:samps)=vs(segBeg(segi):(segBeg(segi)+samps-1));
        end
        g=G2(X);
        maxG2(ti,ratei)=max(g);
        sumG2(ti,ratei)=sum(g(find(g>1)));
    end
end
maxG2
sumG2

table1=NaN;
table1(2:10,1)=[0.125;0.25;0.5;1;2;4;8;16;32];
table1(1,2:5)=[4,8,16,32];
table1(2:end,2:end)=sumG2(:,3:6);
rat=table1(2:end,2:end-1)./table1(2:end,3:end);

%% simulation 

