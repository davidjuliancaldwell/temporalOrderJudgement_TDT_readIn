% Clear variables we don't want to save
clearvars DA
blockName = getLatestFile_TOJ(tank);
save([tank, '\', blockName, '_TOJ.mat']);



