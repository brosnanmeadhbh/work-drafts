
cd /home/yuval/Data/marik/som2/1
load grid
Grid=grid;
clear grid
load ../avgFilt avg1_handR
data=avg1_handR;clear avg*
hs=ft_read_headshape('hs_file')
hs=hs.pnt*1000;

cfg=[];
cfg.latency=[data.time(138) data.time(138)];
cfg.nonlinear='no';
cfg.grid=Grid;
cfg.symmetry='y';
cfg.method='pinv';
[dip2pinv,Rpinv]=dipolefitBIU(cfg,data);

corr(dip2pinv.Vmodel,dip2pinv.Vdata).^2

cfg.method='*';
[dip2mu,Rmu]=dipolefitBIU(cfg,data);
corr(dip2mu.Vmodel,dip2mu.Vdata).^2

figure;
scatter3pnt(hs,1,'k');hold on
scatter3pnt(cfg.grid.pos(cfg.grid.inside,:),25,Rmu(cfg.grid.inside))
view(160,0)
figure;
scatter3pnt(hs,1,'k');hold on
scatter3pnt(cfg.grid.pos(cfg.grid.inside,:),25,Rpinv(cfg.grid.inside))
view(160,0)

cfg.method='fieldTrip';
[dip2ft]=dipolefitBIU(cfg,data);
corr(dip2ft.Vmodel,dip2ft.Vdata).^2






cfg=[];
cfg.latency=[data.time(138) data.time(138)];
cfg.nonlinear='no';
cfg.grid=Grid;
dipFT1=dipolefitBIU(cfg,data);

cfg.method='pinv';
dipPI1=dipolefitBIU(cfg,data);



maxi=dipPI1.grid_index;
lf=Grid.leadfield{maxi};
Vmodel=lf*dipFT1.dip.mom; % [dipFT1.dip.mom'*lf']'; 
dipPI1.Vmodel
dipFT1.Vmodel

[~,gof]=fit(dipPI1.Vmodel,dipPI1.Vdata,'poly1');

cfg=[];
cfg.latency=[data.time(138) data.time(138)];
cfg.nonlinear='no';
cfg.grid=grid;
cfg.method='\';
dipLD1=dipolefitBIU(cfg,data);

[~,gof]=fit(dipLD1.Vmodel,dipLD1.Vdata,'poly1');


cfg=[];
cfg.latency=[data.time(138) data.time(138)];
cfg.nonlinear='no';
cfg.grid=grid;
cfg.method='*';
dipM1=dipolefitBIU(cfg,data);

cfg=[];
cfg.latency=[data.time(138) data.time(138)];
cfg.nonlinear='no';
cfg.grid=Grid;
cfg.symmetry='y';
cfg.method='pinv';
dip2=dipolefitBIU(cfg,data);
