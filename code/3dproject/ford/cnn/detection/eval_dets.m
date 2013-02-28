function [ap prec rec] = eval_dets(BB,confidence,gt,draw,ids,npos)

% sort detections by decreasing confidence
[sc,si]=sort(-confidence);
ids=ids(si);
BB=BB(:,si);

% assign detections to ground truth objects
nd=length(confidence);
tp=zeros(nd,1);
fp=zeros(nd,1);
tic;
cls = 'car';
for d=1:nd
    % display progress
    if toc>1
        fprintf('%s: pr: compute: %d/%d\n',cls,d,nd);
        drawnow;
        tic;
    end
    
    % find ground truth image
	disp(d);
	disp(ids(d));
    i=ids(d);
    if isempty(i)
        error('unrecognized image "%s"',ids(d));
    elseif length(i)>1
        error('multiple image "%s"',ids(d));
    end

    % assign detection to ground truth object if any
    bb=BB(:,d);
    ovmax=-inf;
    for j=1:size(gt(i).BB,2)
        bbgt=gt(i).BB(:,j);
        bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
        iw=bi(3)-bi(1)+1;
        ih=bi(4)-bi(2)+1;
        if iw>0 & ih>0                
            % compute overlap as area of intersection / area of union
            ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
               (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
               iw*ih;
            ov=iw*ih/ua;
            if ov>ovmax
                ovmax=ov;
                jmax=j;
            end
        end
    end
    % assign detection as true positive/don't care/false positive
    if ovmax>=.5
        if ~gt(i).diff(jmax)
            if ~gt(i).det(jmax)
                tp(d)=1;            % true positive
                gt(i).det(jmax)=true;
            else
                fp(d)=1;            % false positive (multiple detection)
            end
        end
    else
        fp(d)=1;                    % false positive
    end
end

disp('saving vars now');
save('fpvars','fp');
save('tpvars','tp');
% compute precision/recall
fp=cumsum(fp);
tp=cumsum(tp);
rec=tp/npos;
prec=tp./(fp+tp);
save('gt_matrix','gt');

% compute average precision

ap=0;
for t=0:0.1:1
    p=max(prec(rec>=t));
    if isempty(p)
        p=0;
    end
    ap=ap+p/11;
end

if draw
    fprintf('\n Kri - - VOCevaldet drawing the curve ------------------------------------------------------------------- \n')
    % plot precision/recall
    plot(rec,prec,'-');
    grid;
    xlabel 'recall'
    ylabel 'precision'
    title(sprintf('class: %s, AP = %.3f',cls,ap));
end