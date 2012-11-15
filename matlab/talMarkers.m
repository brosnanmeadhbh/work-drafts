function talMarkers(subs,cond)
pat='/media/Elements/MEG/tal';
cd (pat)
for subi=1:length(subs)
    cd (pat)
    sub=subs{subi};
    display(['BEGGINING WITH ',sub]);
    cd ([sub,'/',sub,'/0.14d1']);
    conditions=textread('conditions','%s');
    condcell=find(strcmp(cond,conditions));
    indiv=talIndivPathH(sub,cond,pat)
    for condi=1:length(condcell);
        eval(['path2file=indiv.path',num2str(condi),';'])
        source= conditions{condcell(condi)+2};
        cd(path2file)
        if ~exist([cond,'MarkerFile.mrk'],'file')
            if strcmp('rest',cond)
                load(['/media/Elements/MEG/tal/s',sub,'_pow94_',num2str(condi)])
                epochs94=pow.cfg.previous.trl(:,1)./1017.25;epochs94=epochs94';
                load(['/media/Elements/MEG/tal/s',sub,'_pow92_',num2str(condi)])
                epochs92=pow.cfg.previous.trl(:,1)./1017.25;epochs92=epochs92';
                Trig2mark('eyesClosed',epochs94,'eyesOpen',epochs92)
            elseif strcmp('timeProd',cond)
                load(['/media/Elements/MEG/tal/s',sub,'_pow112'])
                epochs112=pow.cfg.previous.trl(:,1)./1017.25;epochs112=epochs112';
                Trig2mark('timeProd32',epochs112)
            end
            eval(['!mv MarkerFile.mrk ',cond,'MarkerFile.mrk'])
        end
        if ~exist('warped+orig.BRIK','file')
            if ~exist('T.nii','file')
                fitMRI2hs(source);
            end
        end
        if ~exist('HS+orig.BRIK','file')
            hs2afni
        end
    end
end
end
