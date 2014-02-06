cd /home/yuval/Data/epilepsy/b162b/1
fn='c,rfhp1.0Hz';

!SAMcov64 -d lf,hb_c,rfhp1.0Hz -r 1 -m gamma -v
!SAMwts64 -d lf,hb_c,rfhp1.0Hz -r 1 -m  gamma -c Alla -v
cd 1/SAM
[~,~, ActWgts]=readWeights('gamma,40-130Hz,Alla.wts');
cd ..
fn='lf,hb_c,rfhp1.0Hz';
hdr=ft_read_header(fn);
s1=round(hdr.Fs*115);
trl=s1:round(hdr.Fs):s1+19*hdr.Fs;
trl=trl';
trl(:,2)=trl+round(hdr.Fs);
trl(:,3)=0;
cfg=[];
cfg.trl=trl;
cfg.dataset=fn;
cfg.channel='MEG';
cfg.hpfilter='yes';
cfg.hpfreq=40;
raw=ft_preprocessing(cfg);
ns=mean(abs(ActWgts),2);
pow=zeros(length(ActWgts),length(trl));
for triali=1:length(trl)
    pow(:,triali)=mean(abs(ActWgts*raw.trial{1,triali}),2)./ns;
end
pow=pow.*(10^13);
cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
cfg.prefix='gamma';
cfg.TR =1000;
cfg.torig = 115*1000;
VS2Brik(cfg,pow);
!3dcalc -a maskRS+orig -b gamma+orig -exp 'b*ispositive(a)' -prefix gammaMovie
%% denoised movie
load hp20_new_data_100_epoch500_r3
samps=trl(:,1)-trl(1,1)+1;
pow=zeros(length(ActWgts),length(trl));
for triali=1:length(trl)-1
    pow(:,triali)=mean(abs(ActWgts*new_data(:,samps(triali):samps(triali)+679)),2)./ns;
end
pow=pow.*(10^13);
cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
cfg.prefix='gammaDN';
cfg.TR =1000;
cfg.torig = 115*1000;
VS2Brik(cfg,pow);


!3dcalc -a maskRS+orig -b gammaDN+orig -exp 'b*ispositive(a)' -prefix gammaDNmovie
%% denoised weights
cd /home/yuval/Data/epilepsy/b162b/1
fn='lf,hb_c,rfhp1.0Hz';
hdr=ft_read_header(fn);
s1=round(hdr.Fs*115);
trl=[1,hdr.nSamples,0];
cfg=[];
cfg.trl=trl;
cfg.dataset=fn;
cfg.channel='MEG';
cfg.hpfilter='yes';
cfg.hpfreq=20;
cfg.demean='yes';
raw=ft_preprocessing(cfg);
rewrite_pdf(raw.trial{1,1},raw.label,'c,rfhp1.0Hz','hp20');
load hp20_new_data_100_epoch500_r3
dn=raw;
dn.trial{1,1}(:,s1:(s1+length(new_data)-1))=new_data;
rewrite_pdf(dn.trial{1,1},dn.label,'c,rfhp1.0Hz','hp20DN');

cd /home/yuval/Data/epilepsy/b162b
!SAMcov64 -d hp20_c,rfhp1.0Hz -r 1 -m gamma -v
!SAMwts64 -d hp20_c,rfhp1.0Hz -r 1 -m  gamma -c Alla -v
!cp 1/SAM/gamma,40-130Hz,Alla.wts 1/SAM/hp20.wts
!SAMcov64 -d hp20DN_c,rfhp1.0Hz -r 1 -m gamma -v
!SAMwts64 -d hp20DN_c,rfhp1.0Hz -r 1 -m  gamma -c Alla -v
!cp 1/SAM/gamma,40-130Hz,Alla.wts 1/SAM/hp20DN.wts

cd 1/SAM
[~,~, ActWgts]=readWeights('hp20.wts');
cd ..
fn='hp20_c,rfhp1.0Hz';
hdr=ft_read_header(fn);
s1=round(hdr.Fs*115);
trl=s1:round(hdr.Fs):s1+19*hdr.Fs;
trl=trl';
trl(:,2)=trl+round(hdr.Fs);
trl(:,3)=0;
cfg=[];
cfg.trl=trl;
cfg.dataset=fn;
cfg.channel='MEG';
cfg.bpfilter='yes';
cfg.bpfreq=[40 130];
raw=ft_preprocessing(cfg);
ns=mean(abs(ActWgts),2);
pow=zeros(length(ActWgts),length(trl)-1);
for triali=1:length(trl)
    pow(:,triali)=mean(abs(ActWgts*raw.trial{1,triali}),2)./ns;
end
pow=pow.*(10^13);
cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
cfg.prefix='hp20';
cfg.TR =1000;
cfg.torig = 115*1000;
VS2Brik(cfg,pow);
!3dcalc -a maskRS+orig -b hp20+orig -exp 'b*ispositive(a)' -prefix hp20Movie
cd SAM
[~,~, ActWgts]=readWeights('hp20DN.wts');
cd ..
% denoised movie
load hp20_new_data_100_epoch500_r3
samps=trl(:,1)-trl(1,1)+1;
pow=zeros(length(ActWgts),length(trl)-1);
for triali=1:length(trl)-1
    pow(:,triali)=mean(abs(ActWgts*new_data(:,samps(triali):samps(triali)+679)),2)./ns;
end
pow=pow.*(10^13);
cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
cfg.prefix='hp20DN';
cfg.TR =1000;
cfg.torig = 115*1000;
VS2Brik(cfg,pow);


!3dcalc -a maskRS+orig -b hp20DN+orig -exp 'b*ispositive(a)' -prefix hp20DNmovie
%% 100-130Hz
cd /home/yuval/Data/epilepsy/b162b

!SAMcov64 -d hp20_c,rfhp1.0Hz -r 1 -m Highgamma -v
!SAMwts64 -d hp20_c,rfhp1.0Hz -r 1 -m  Highgamma -c Alla -v
!cp 1/SAM/Highgamma,100-130Hz,Alla.wts 1/SAM/bp100_130.wts
!SAMcov64 -d hp20DN_c,rfhp1.0Hz -r 1 -m Highgamma -v
!SAMwts64 -d hp20DN_c,rfhp1.0Hz -r 1 -m  Highgamma -c Alla -v
!cp 1/SAM/Highgamma,100-130Hz,Alla.wts 1/SAM/bp100_130DN.wts

cd 1/SAM
[~,~, ActWgts]=readWeights('bp100_130.wts');
cd ..
fn='hp20_c,rfhp1.0Hz';
hdr=ft_read_header(fn);
s1=round(hdr.Fs*115);
trl=s1:round(hdr.Fs):s1+19*hdr.Fs;
trl=trl';
trl(:,2)=trl+round(hdr.Fs);
trl(:,3)=0;
cfg=[];
cfg.trl=trl;
cfg.dataset=fn;
cfg.channel='MEG';
cfg.bpfilter='yes';
cfg.bpfreq=[100 130];
raw=ft_preprocessing(cfg);
ns=mean(abs(ActWgts),2);
pow=zeros(length(ActWgts),length(trl)-1);
for triali=1:length(trl)
    pow(:,triali)=mean(abs(ActWgts*raw.trial{1,triali}),2)./ns;
end
pow=pow.*(10^13);
cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
cfg.prefix='bp100_130';
cfg.TR =1000;
cfg.torig = 115*1000;
VS2Brik(cfg,pow);
!3dcalc -a maskRS+orig -b bp100_130+orig -exp 'b*ispositive(a)' -prefix bp100_130Movie
cd SAM
[~,~, ActWgts]=readWeights('bp100_130DN.wts');
cd ..
fn='hp20DN_c,rfhp1.0Hz';
hdr=ft_read_header(fn);
s1=round(hdr.Fs*115);
trl=s1:round(hdr.Fs):s1+19*hdr.Fs;
trl=trl';
trl(:,2)=trl+round(hdr.Fs);
trl(:,3)=0;
cfg=[];
cfg.trl=trl;
cfg.dataset=fn;
cfg.channel='MEG';
cfg.bpfilter='yes';
cfg.bpfreq=[100 130];
raw=ft_preprocessing(cfg);
ns=mean(abs(ActWgts),2);
pow=zeros(length(ActWgts),length(trl)-1);
for triali=1:length(trl)
    pow(:,triali)=mean(abs(ActWgts*raw.trial{1,triali}),2)./ns;
end
pow=pow.*(10^13);
cfg=[];
cfg.step=5;
cfg.boxSize=[-120 120 -90 90 -20 150];
cfg.prefix='bp100_130DN';
cfg.TR =1000;
cfg.torig = 115*1000;
VS2Brik(cfg,pow);
!3dcalc -a maskRS+orig -b bp100_130DN+orig -exp 'b*ispositive(a)' -prefix bp100_130DNmovie




%     
%     
%     
% cfg=[];
% cfg.bpfilter='yes';
% cfg.bpfreq=[30 75];
% g=ft_preprocessing(cfg,datapca);
% 
% 
% 
% ictal=zeros(length(ActWgts),1);
% for tri=125:134
%     ictal=ictal+mean(abs(ActWgts*g.trial{1,tri}),2);
% end
% ictal=ictal./10;
% preictal=zeros(length(ActWgts),1);
% for tri=115:124
%     preictal=preictal+mean(abs(ActWgts*g.trial{1,tri}),2);
% end
% preictal=preictal./10;
% 
% nai=(ictal-preictal)./preictal;

!3dSkullStrip -input ortho+orig -prefix mask -mask_vol -skulls -o_ply ortho
!3dresample -master gamma+orig -prefix maskRS -inset mask+orig


% ictal=zeros(length(ActWgts),1);
% inside=find(ActWgts(:,1));
% cnt=0;
% utest
% cfg=[];
% cfg.step=5;
% cfg.boxSize=[-120 120 -90 90 -20 150];
% cfg.prefix='gammaU';
% VS2Brik(cfg,ictal);

%%  Nolte

!SAMcov -d lf_c,rfhp1.0Hz -r 1 -m SpikesNolte -v
!SAMwts -d lf_c,rfhp1.0Hz -r 1 -m SpikesNolte -c Global -v
!SAMepi -d lf_c,rfhp1.0Hz -r 1 -m SpikesNolte -v