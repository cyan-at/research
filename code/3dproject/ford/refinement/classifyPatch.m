function [score2D, score3D] = classifyPatch(patch,pc,classifier2D,classifier3D,parameters)
    [label2 score2] = get2Dscore(patch,classifier2D.model,classifier2D.encoder,parameters);
    score2D = (label2==1)*score2;
    
    if (isempty(pc))
        score3D = 0;
        return;
    end
    [label3 score3] = get3Dscore(pc,classifier3D.model,classifier3D.encoder,parameters);
    score3D = (label3==1)*score3;
end

