%% now to fieldtrip beamforming
% first go back to course8 and make sure you already run SAMwts with -t
% pnt.txt option.
cd oddball
load trl

% first we need data
source='c,rfhp0.1Hz';
cfg=[];
cfg.dataset=source;
cfg.trialfun='trialfun_beg';
cfg2=ft_definetrial(cfg);
cfg2.trl=trl;
cfg2.demean='yes';
cfg2.baselinewindow=[-0.2 0];
cfg2.bpfilter='yes';
cfg2.bpfreq=[3 30];
cfg2.channel='MEG'; % or {'MEG','MEGREF'};
data=ft_preprocessing(cfg2);
cfg=[];
cfg.trials=find(data.trialinfo==128);

standard=ft_preprocessing(cfg,data);
cfg=[];
cfg.method='summary'; %trial
cfg.alim=1e-12;
standard=ft_rejectvisual(cfg, standard);

stdAvg=ft_timelockanalysis([],standard);

plot(stdAvg.time,stdAvg.avg);
cfg=[];
cfg.xlim=[0.06 0.06];
cfg.layout='4D248.lay';
cfg.channel='MEG';
ft_topoplotER(cfg,stdAvg);

toi=[0.043657 0.075163];


%load headmodel % it was created in course8 (and 7)
[vol,grid,mesh,M1,single]=headmodel_BIU([],[],[],[],'localspheres');
load ~/ft_BIU/matlab/files/sMRI.mat
mri_realign=sMRI;
mri_realign.transform=inv(M1)*sMRI.transform;


% cov for avged data, toi only + baseline window
source=OBbeamform(stdAvg,toi,'sam',mri_realign)

% cov for whole averaged data
source=OBbeamform1(stdAvg,toi,'sam',mri_realign)

% same but with LCMV
source=OBbeamform1(stdAvg,toi,'lcmv',mri_realign)

% cov for raw data
source=OBbeamform(standard,toi,'sam',mri_realign)

% here we use the output of SAMwts as filter
% similar to cov for raw data

load('SAM/pnt.txt.mat')
filter=wts2filter(ActWgts,grid.inside,size(grid.outside,1));
source=OBbeamform(stdAvg,toi,'SAM',mri_realign,filter)

source=OBmne(stdAvg,toi,mri_realign)

%% below see a brave attempt to use MNE with a single shell.

load ~/ft_BIU/matlab/files/sMRI.mat
mri_realign=sMRI;
mri_realign.transform=inv(M1)*sMRI.transform;
cfg           = [];
cfg.coordsys  = '4d';
cfg.output    = {'brain'};
seg           = ft_volumesegment(cfg, mri_realign);

hs=ft_convert_units(ft_read_headshape('hs_file'),'mm')

cfg = [];
volseg = ft_prepare_singleshell(cfg,seg);
volseg=ft_convert_units(volseg,'mm');
plot3pnt(hs.pnt,'rx');hold on;ft_plot_mesh(volseg.bnd);

cfg = [];
cfg.covariance = 'yes';
cfg.covariancewindow = [-inf 0];
cov = ft_timelockanalysis(cfg, stdAvg);

cfg = [];
cfg.grad = ft_convert_units(stdAvg.grad,'mm');                      % sensor positions
cfg.channel ='MEG';   % the used channels
cfg.grid.pos = volseg.bnd.pnt;              % source points
cfg.grid.inside = 1:size(volseg.bnd.pnt,1); % all source points are inside of the brain
cfg.vol = vol;                               % volume conduction model
leadfield = ft_prepare_leadfield(cfg);
cfg=[];
cfg.method = 'mne';
cfg.grid = leadfield;
cfg.vol = vol;
cfg.mne.lambda = 1e8;

source = ft_sourceanalysis(cfg,cov);


ft_plot_mesh(volseg.bnd, 'vertexcolor', source.avg.pow(:,264));


cfg = [];
cfg.projectmom = 'yes';
sourced = ft_sourcedescriptives(cfg,source);
figure;
ft_plot_mesh(volseg.bnd, 'vertexcolor', sourced.avg.pow(:,264));

cfg = [];
cfg.funparameter = 'avg.pow';
sourced.tri=volseg.bnd.tri;
figure;
ft_sourcemovie(cfg,sourced);