function Endnote_Pass(filePath)

finishedDir = [filePath '\Finished'];
workingDir = [filePath '\Working'];

files = dir(workingDir);
L = length(files);
index = false(1, L);
for k = 1:L
    M = length(files(k).name);
    if M > 4 && strcmp(files(k).name(M-3:M), '.c3d')
        index(k) = true;
    end
end

files = files(index);
for ii = 1:length(files)



File = files(ii).name;
workingFilename = [filePath '\Working\' File(1:length(File)-4)];
disp(['Creating Endnote Filter for trial: ' File(1:length(File)-4)])

    Create_Endnote_Filter(filePath,workingFilename)

end


files = dir(finishedDir);
L = length(files);
index = false(1, L);
for k = 1:L
    M = length(files(k).name);
    if M > 4 && strcmp(files(k).name(M-3:M), '.c3d')
        index(k) = true;
    end
end

files = files(index);
for ii = 1:length(files)



File = files(ii).name;
finishedFilename = [filePath '\Finished\' File(1:length(File)-4)];
disp(['Creating Endnote Filter for trial: ' File(1:length(File)-4)])

    Create_Endnote_Filter(filePath, finishedFilename)

end
