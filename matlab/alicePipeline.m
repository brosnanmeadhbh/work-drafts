%% exploring results
% evoked response

open aliceStatExplore1



%% subject by subject
subfolder='mark';
alice2(subFolder);
aliceReduceAvg(subFolder);
aliceAlpha(subFolder);
aliceWbW(subFolder);

%% run all
sf={'idan'  'inbal'  'liron'  'maor'  'odelia'	'ohad'  'yoni' 'mark'};
for i=1:length(sf)
    % alice2(sf{i});
    % aliceReduceAvg(sf{i});
    % aliceAlpha(sf{i});
    aliceWbW(sf{i});
    %     cd(sf{i})
    %     movefile('files/topo*','files/prev/')
    %movefile('files/prev/seg*','files/')
%     cd ..
end

%% find timing of components
open aliceCompLimSub
% max([EEG,MEG]) to min([EEG,MEG])
comps=aliceCompLimSub2;
%% calculating area
aliceTables
aliceTables('LR');
aliceTables('Post');
aliceTables('PostLR');
% ci=1 for N100, 2 for N170, 3 for M100, 4 for M170
% test tamil effect for N100, whole head rms.
[p,stats,X]=aliceStats(1,'z','tablesPost','tamil')
[p,stats,X]=aliceStats(3,'z','tablesPost','tamil')
[p,stats,X]=aliceStats(1,'z','tablesWH','loud')
[p,stats,X]=aliceStats(2,'z','tablesR','loud','U')
[p,stats,X]=aliceStats(1,'z','tablesPost','WBW')
[p,stats,X]=aliceStats(3,'z','tablesPost','WBW')
[p,stats,X]=aliceStats(2,'z','tablesPost','WBW')
[p,stats,X]=aliceStats(1,'z','tablesWH')
[p,stats,X]=aliceStats(1,'','tablesLR')

[p,stats,X]=aliceStats(1,'z','tablesPost','tamil','U')
[p,stats,X]=aliceStats(3,'z','tablesPost','tamil','U')
[p,stats,X]=aliceStats(1,'z','tablesWH','loud','U')

%% LR
aliceLR
aliceLR1('alice')
aliceGA('LR')
aliceGA('LRalice')
aliceLR1('6101820')
cd /home/yuval/Copy/MEGdata/alice/ga
stat=statPlot('GavgE10LR','GavgE8_12LR',[0.17 0.17],[],'paired-ttest') % tamil
stat=statPlot('GavgE10LR','GavgE8_12LR',[0.1 0.1],[],'paired-ttest')
stat=statPlot('GavgE20LR','GavgE2_4LR',[0.1 0.1],[],'paired-ttest') % WbW
stat=statPlot('GavgE20LR','GavgE2_4LR',[0.17 0.17],[],'paired-ttest')
stat=statPlot('GavgE18LR','GavgE16LR',[0.17 0.17],[],'paired-ttest')
stat=statPlot('GavgM18LR','GavgM16LR',[0.17 0.17],[],'paired-ttest')
stat=statPlot('GavgM10LR','GavgM8_12LR',[0.17 0.17],[],'paired-ttest') % tamil

%stat=statPlot('GavgM10LR','GavgM8_12LR',[0.17 0.17],[],'paired-ttest') % tamil
load /home/yuval/Copy/MEGdata/alice/ga/GavgEaliceLR.mat
load /home/yuval/Copy/MEGdata/alice/ga/GavgMaliceLR.mat
cfg=[];
cfg.layout='4D248.lay';
cfg.xlim=[0.17 0.17];
figure;
ft_topoplotER(cfg,GavgMaliceLR)
cfg=[];
cfg.layout='WG32.lay';
cfg.xlim=[0.17 0.17];
figure;
ft_topoplotER(cfg,GavgEaliceLR)

aliceTtest0('GavgMaliceLR',0.17,0);

aliceTtest0('GavgMaliceLR',0.17,1);

aliceTtest0('GavgM20LR',0.17,1); % Word bt Word
aliceTtest0('GavgM20LR',0.1,1);
aliceTtest0('GavgE20LR',0.17,1);
aliceTtest0('GavgE20LR',0.1,1);

%% Freq LR differences
aliceGA('frLR')
aliceGA('frLRalice')
aliceGA('frLRrest')
aliceGA('frLRwbw')


stat=statPlot('GavgFrM20LR','GavgFrMrestLR',[9 9],[-3e-27 3e-27],'paired-ttest') % rest
stat=statPlot('GavgFrM20LR','GavgFrMaliceLR',[9 9],[-3e-27 3e-27],'paired-ttest') % rest


stat=statPlot('GavgFrM2LR','GavgFrM100LR',[10 10],[-3e-27 3e-27],'paired-ttest') % rest
aliceTtest0('GavgFrM100LR',10,1);

open aliceStatExplore

%% Fr differences
aliceGA('fr')
aliceGA('frAlice')
aliceGA('frRest')



stat=statPlot('GavgFrMrest','GavgFrMalice',[9 9],[0 1e-26],'paired-ttest')
stat=statPlot('GavgFrErest','GavgFrEalice',[9 9],[0 5],'paired-ttest')
stat=statPlot('GavgFrM20','GavgFrMrest',[9 9],[0 1e-26],'paired-ttest')

stat=statPlot('GavgFrM8','GavgFrM10',[10 10],[0 1e-26],'paired-ttest') 
stat=statPlot('GavgFrM102','GavgFrM100',[9 9],[0 1e-26],'paired-ttest') 
stat=statPlot('GavgFrE100','GavgFrE2',[9 9],[0 5],'paired-ttest')
stat=statPlot('GavgFrErest','GavgFrE2',[9 9],[0 5],'paired-ttest')
%% coh
aliceGA('coh')
stat=statPlot('GavgCohM10','GavgCohMalice',[9 9],[0 1],'paired-ttest')
stat=statPlot('GavgCohE10','GavgCohEalice',[9 9],[0 1],'paired-ttest')
stat=statPlot('GavgCohMrest','GavgCohMalice',[9 9],[0 1],'paired-ttest')

%% N400
aliceTtest0('GavgEaliceLR1',0.36,1);
aliceTtest0('GavgMaliceLR1',0.36,1);
alicePlotLR(0.36)

alicePlotLR(0.17)
% see plotN400.m



%% old

alice1('maor')

alice1('yoni',1);
aliceReduceAvg('maor')
aliceAlpha('maor')

subFolder={'yoni','idan','liron'};
for i=1:3
    sf=subFolder{i};
    aliceReduceAvg(sf)
    aliceAlpha(sf)
end

aliceWbW('liron')

aliceTables('maor') % blink issues with speach paragraph

subFolder='odelia';
alice1(subFolder);
aliceReduceAvg(subFolder)
aliceAlpha(subFolder)
aliceWbW(subFolder)

open alicePlots

open aliceTestCompLimMethod

open aliceCompLimSub
% 
% times=findCompLims('rms',[],avgE2);
% timeCourse=findCompLims('yzero',[],avgE2,avgE4,avgE6,avgE8,avgE10,avgE12,avgE14,avgE16,avgE18);
% timeCourseO=findCompLims('yzero',{'O1','O2','Oz'},avgE2,avgE4,avgE6,avgE8,avgE10,avgE12,avgE14,avgE16,avgE18);
% timeCourseO=findCompLims('absMean',{'O1','O2','Oz'},avgE2,avgE4,avgE6,avgE8,avgE10,avgE12,avgE14,avgE16,avgE18);


