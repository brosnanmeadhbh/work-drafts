% b162b
% t=[121 681 596];
% matlabpool
% parfor runi=1:3
%     marikSAMloop2([t(runi)-30 t(runi)+15],num2str(runi));
% end
% parfor runi=1:3
%     marikSAMloop([t(runi)-30 t(runi)+15],num2str(runi));
% end

% b162b
t=121;
marikSAMloop([t-30 t+15],'1','c,rfhp1.0Hz','/home/yuval/Data/epilepsy/b162b');
marikSAMg2
runi=1;
time=[t(runi)-30 t(runi)+15];
% b022
t=63;
marikSAMloop2([t-30 t+15],'ictus','noECG_c,rfhp1.0Hz,ee,ee','/home/yuval/Data/epilepsy/b022');
marikSAMloop([t-30 t+15],'ictus','noECG_c,rfhp1.0Hz,ee,ee','/home/yuval/Data/epilepsy/b022');

marikSAMloop1([t-30 t+15],'ictus','noECG_c,rfhp1.0Hz,ee,ee','/home/yuval/Data/epilepsy/b022');
t=121;
marikSAMloop1([t-30 t+15],'1','c,rfhp1.0Hz','/home/yuval/Data/epilepsy/b162b');

cd /home/yuval/Data/epilepsy/p006/1
open scrap
