cd /home/yuval/Copy/MEGdata/alice/idan

trig=readTrig_BIU;
trig=clearTrig(trig);
restS=find(trig==100,1,'last'); % idan had 100 in the beginning too
cfg=[];
cfg.trl=[restS,restS+round(1017.23*120),0];
cfg.dataset=source;
cfg.channel='MEG';
mag=ft_preprocessing(cfg);
cfg.channel='MCxaA';
ref=ft_preprocessing(cfg);
cfg=rmfield(cfg,'trl');
refAll=ft_preprocessing(cfg);
% [four,F]=fftBasic(ref.trial{1,1},ref.fsample);
% [~,refi]=max(abs(four(:,50))./mean(abs(four(:,60:90)),2));
% ref.label(refi)
[f100,F100]=fft100(refAll.trial{1,1},ref.fsample);

Hz45i=nearest(F100,45);
Hz55i=nearest(F100,55);
[~,maxPow]=max(abs(f100(Hz45i:Hz55i)));
maxPow=F100(maxPow+Hz45i-1);
trig=readTrig_BIU;
trig=trig(restS:restS+round(1017.23*120));
trig=bitand(uint16(trig),256);
correctLF(mag.trial{1,1},mag.fsample,'time','adaptive',50,4);
correctLF(mag.trial{1,1},mag.fsample,'time','adaptive',maxPow,4);
correctLF(mag.trial{1,1},mag.fsample,ref.trial{1,1},'adaptive',maxPow,4);
correctLF(mag.trial{1,1},mag.fsample,trig,'adaptive',maxPow,4);

cfg=[];
cfg.trl=[restS,restS+round(1017.23*120),0];
cfg.dataset=source;
cfg.channel='MEG';
cfg.hpfilter='yes';
cfg.hpfreq=1;
cfg.demean='yes';
magHP=ft_preprocessing(cfg);
correctLF(magHP.trial{1,1},mag.fsample,'time','adaptive',50,4);
correctLF(magHP.trial{1,1},mag.fsample,'time',50,50,4);
% check optimal freq
% compare trig - constructed - ref
% constructed: check num cycle effect
% test epilepsy

cd /home/yuval/Data/epilepsy/b162b/1
hdr=ft_read_header(source);
t=121;
samp=round((t-30.5)*hdr.Fs);
samp(1,2)=samp+677;
for trli=2:46
    samp(trli,1)=samp(trli-1,2)+1;
    samp(trli,2)=samp(trli,1)+677;
end

time=-30:15;
% time0=[-30.5:14.5]'+t;
% trl=[round(t-30*hdr.Fs),;
% trl(:,2)=trl+round(hdr.Fs);
% trl(:,3)=-round(hdr.Fs)/2;
cfg=[];
cfg.demean='yes';
cfg.trl=samp;
cfg.trl(:,3)=-678/2;
cfg.dataset=source;
cfg.channel='MEG';
raw=ft_preprocessing(cfg);
cfg.trl=[samp(1,1) samp(end,2) -round(30.5*hdr.Fs)];
rawCont=ft_preprocessing(cfg);


cfg=[];
%cfg.trials=find(datacln.trialinfo==222);
cfg.output       = 'pow';
cfg.channel      = 'MEG';
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 1:100;
cfg.feedback='no';
cfg.keeptrials='yes';
FrAll = ft_freqanalysis(cfg, raw);

% plot results for alpha
cfgp = [];
cfgp.xlim = [50 50];
cfgp.layout       = '4D248.lay';
cfgp.interactive='yes';
cfgp.trials=43;
figure;ft_topoplotER(cfgp, FrAll);
[~,chi]=ismember('A161',raw.label)
figure;plot(time,FrAll.powspctrm(:,chi,50))

%  hb=correctHB(rawCont.trial{1,1},rawCont.fsample);
%  HB=raw;
%  for trli=1:46
%      samples=samp(trli,1):samp(trli,2);
%      samples=samples-samp(1,1)+1;
%      HB.trial{1,trli}(:,:)=hb(:,samples);
%  end
%  FrHB = ft_freqanalysis(cfg, HB);
%  figure;ft_topoplotER(cfgp, FrHB);

lf=correctLF(rawCont.trial{1,1},rawCont.fsample,'time',50,50,4);
LF=raw;
for trli=1:46
    samples=samp(trli,1):samp(trli,2);
    samples=samples-samp(1,1)+1;
    LF.trial{1,trli}(:,:)=lf(:,samples);
end
LF=correctBL(LF);
FrLF = ft_freqanalysis(cfg, LF);
figure;ft_topoplotER(cfgp, FrLF);
figure;plot(time,FrAll.powspctrm(:,chi,50),'r')
hold on
plot(time,FrLF.powspctrm(:,chi,50),'k')

trig=readTrig_BIU;
trig=trig(samp(1,1):samp(end,2));
trig=bitand(uint16(trig),256);
lfTrig=correctLF(rawCont.trial{1,1},rawCont.fsample,trig,'adaptive',50);
LFtrig=raw;
for trli=1:46
    samples=samp(trli,1):samp(trli,2);
    samples=samples-samp(1,1)+1;
    LFtrig.trial{1,trli}(:,:)=lfTrig(:,samples);
end
LFtrig=correctBL(LFtrig);
FrLFtrig = ft_freqanalysis(cfg, LFtrig);
plot(time,FrLFtrig.powspctrm(:,chi,50),'g')


trig=readTrig_BIU;
%trig=trig(samp(1,1):samp(end,2));
trig=bitand(uint16(trig),256);
lfTrigG=correctLF(source,[],trig,'GLOBAL',50);
lfTrigG=lfTrigG(:,samp(1,1):samp(end,2));
LFtrigG=raw;
for trli=1:46
    samples=samp(trli,1):samp(trli,2);
    samples=samples-samp(1,1)+1;
    LFtrigG.trial{1,trli}(:,:)=lfTrigG(:,samples);
end
for chani=1:248;
    LFtrigG.label{chani,1}=['A',num2str(chani)];
end
LFtrigG=correctBL(LFtrigG);
FrLFtrigG = ft_freqanalysis(cfg, LFtrigG);
plot(time,FrLFtrigG.powspctrm(:,166,50),'m')
figure;ft_topoplotER(cfgp, FrLFtrigG);
figure;ft_topoplotER(cfgp, FrAll);
FrDif=FrAll;
bl=mean(FrAll.powspctrm(1:30,:,:),1);
for trli=31:46
   FrDif.powspctrm(trli,:,:)= FrDif.powspctrm(trli,:,:)-bl;
end
cfgp.zlim=[-0.5*1e-26 0.5*1e-26];
figure;ft_topoplotER(cfgp, FrDif);
figure;ft_topoplotER(cfgp, FrLFtrigG,FrDif);

p=pdf4D(source);
createCleanFile(p,source,'byLF',256,'method','phasePrecession');

cfg=[];
cfg.demean='yes';
cfg.trl=samp;
cfg.trl(:,3)=-678/2;
cfg.dataset=['lf_',source];
cfg.channel='MEG';
rawLF=ft_preprocessing(cfg);
rawLF=correctBL(rawLF);
cfg=[];
%cfg.trials=find(datacln.trialinfo==222);
cfg.output       = 'pow';
cfg.channel      = 'MEG';
cfg.method       = 'mtmfft';
cfg.taper        = 'hanning';
cfg.foi          = 1:100;
cfg.feedback='no';
cfg.keeptrials='yes';
FrLFccf = ft_freqanalysis(cfg, rawLF);

plot(time,FrLFccf.powspctrm(:,chi,50),'k')

for bli=1:30
    if bli==1
        [fA245_1,F]=fftBasic(raw.trial{1,bli}(64,:),raw.fsample);
        [fA161_1,F]=fftBasic(raw.trial{1,bli}(146,:),raw.fsample);
    else
        fA245_1=fA245_1+fftBasic(raw.trial{1,bli}(64,:),raw.fsample);
        fA161_1=fA161_1+fftBasic(raw.trial{1,bli}(146,:),raw.fsample);
    end
end
fA245_1=abs(fA245_1)./30;
fA161_1=abs(fA161_1)./30;
for icti=31:46
    if icti==31
        [fA245_2,F]=fftBasic(raw.trial{1,icti}(64,:),raw.fsample);
        [fA161_2,F]=fftBasic(raw.trial{1,icti}(146,:),raw.fsample);
    else
        fA245_2=fA245_2+fftBasic(raw.trial{1,icti}(64,:),raw.fsample);
        fA161_2=fA161_2+fftBasic(raw.trial{1,icti}(146,:),raw.fsample);
    end
end
fA245_2=abs(fA245_2)./16;
fA161_2=abs(fA161_2)./16;


for bli=1:30
    if bli==1
        [fA245_1lf,F]=fftBasic(rawLF.trial{1,bli}(64,:),raw.fsample);
        [fA161_1lf,F]=fftBasic(rawLF.trial{1,bli}(146,:),raw.fsample);
    else
        fA245_1lf=fA245_1lf+fftBasic(rawLF.trial{1,bli}(64,:),raw.fsample);
        fA161_1lf=fA161_1lf+fftBasic(rawLF.trial{1,bli}(146,:),raw.fsample);
    end
end
fA245_1lf=abs(fA245_1lf)./30;
fA161_1lf=abs(fA161_1lf)./30;
for icti=31:46
    if icti==31
        [fA245_2lf,F]=fftBasic(rawLF.trial{1,icti}(64,:),raw.fsample);
        [fA161_2lf,F]=fftBasic(rawLF.trial{1,icti}(146,:),raw.fsample);
    else
        fA245_2lf=fA245_2lf+fftBasic(rawLF.trial{1,icti}(64,:),raw.fsample);
        fA161_2lf=fA161_2lf+fftBasic(rawLF.trial{1,icti}(146,:),raw.fsample);
    end
end
fA245_2lf=abs(fA245_2lf)./16;
fA161_2lf=abs(fA161_2lf)./16;
figure;
% plot(F,abs(fA245_1),'b')
% hold on
% plot(F,abs(fA245_2),'r')

figure;
plot(F,abs(fA161_1),'r')
hold on
plot(F,abs(fA161_2),'k')
plot(F,abs(fA161_1lf),'b')
plot(F,abs(fA161_2lf),'g')
legend('BLraw','ICTraw','BLclean','ICTclean')


for bli=1:30
    if bli==1
        [f_1,F]=fftBasic(raw.trial{1,bli},raw.fsample);
        f_1=abs(f_1).^2;
    else
        f_1=f_1+abs(fftBasic(raw.trial{1,bli},raw.fsample)).^2;
    end
end
f_1=f_1./30;
for icti=31:46
    if icti==31
        f_2=fftBasic(raw.trial{1,icti},raw.fsample);
        f_2=abs(f_2).^2;
    else
        f_2=f_2+abs(fftBasic(raw.trial{1,icti},raw.fsample)).^2;
    end
end
f_2=f_2./16;

for bli=1:30
    if bli==1
        [fcl_1,F]=fftBasic(rawLF.trial{1,bli},rawLF.fsample);
        fcl_1=abs(fcl_1).^2;
    else
        fcl_1=fcl_1+abs(fftBasic(rawLF.trial{1,bli},rawLF.fsample)).^2;
    end
end
fcl_1=fcl_1./30;
for icti=31:46
    if icti==31
        fcl_2=fftBasic(rawLF.trial{1,icti},rawLF.fsample);
        fcl_2=abs(fcl_2).^2;
    else
        fcl_2=fcl_2+abs(fftBasic(rawLF.trial{1,icti},rawLF.fsample)).^2;
    end
end
fcl_2=fcl_2./16;
fftRaw=FrAll;
fftRaw.powspctrm=[];
fftRaw.powspctrm(1,1:248,1:339)=f_1;
fftRawIct=FrAll;
fftRawIct.powspctrm=[];
fftRawIct.powspctrm(1,1:248,1:339)=f_2;
fftCl=FrAll;
fftCl.powspctrm=[];
fftCl.powspctrm(1,1:248,1:339)=fcl_1;
fftClIct=FrAll;
fftClIct.powspctrm=[];
fftClIct.powspctrm(1,1:248,1:339)=fcl_2;
fftRawDif=fftRaw;
fftRawDif.powspctrm=fftRawIct.powspctrm-fftRaw.powspctrm;
cfgp.zlim=[0 1e-21];
figure;ft_topoplotER(cfgp, fftCl,fftClIct,fftRaw,fftRawIct);
cfgp.zlim=[0 5*1e-22];
figure;ft_topoplotER(cfgp,fftClIct,fftRawDif);
freq=50;
for icti=1:46
        ff=fftBasic(rawLF.trial{1,icti}(146,:),rawLF.fsample);
        fcl(icti)=abs(ff(freq)).^2;
        ff=fftBasic(raw.trial{1,icti}(146,:),raw.fsample);
        f(icti)=abs(ff(freq)).^2;
end
figure;plot(time,fcl)
hold on
plot(time,f,'r')
f=[];fcl=[];
for icti=1:46
        ff=fftBasic(rawLF.trial{1,icti}(146,:),rawLF.fsample);
        fcl(icti,1:100)=abs(ff(1:100)).^2;
        ff=fftBasic(raw.trial{1,icti}(146,:),raw.fsample);
        f(icti,1:100)=abs(ff(1:100)).^2;
end
figure;
%imagesc(f')
pcolor(sqrt(f)')
figure;
pcolor(sqrt(fcl)')

% check again with adaptive, time etc