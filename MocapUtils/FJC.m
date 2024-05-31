function FJC(path)
[~,status_result] = system('tasklist /FI "imagename eq nexus.exe" /fo table /nh');
if ~contains(status_result, ' 1 ')
    !C:\Program Files\Vicon\Nexus2.13\Nexus.exe &
    pause(60)
end
vicon = ViconNexus();
FJCs = dir(fullfile(path,'*FJC*.x1d'));
Fjcs = dir(fullfile(path,'*Fjc*.x1d'));
fjcs = dir(fullfile(path,'*fjc*.x1d'));
allFJCS = [FJCs Fjcs fjcs];
fjcFile = allFJCS(1);
fjcFile = fjcFile.name;
fjcFile = [path '\' fjcFile(1:length(fjcFile)-4)]

vicon.OpenTrial(fjcFile, 60);
vicon.RunPipeline('Reconstruct and Label', '', 300);
vicon.RunPipeline('Calibration', '', 300);
vicon.SaveTrial(60);
vicon.OpenTrial(fjcFile, 60);

vicon.RunPipeline('Reconstruct and Label', '', 300);
vicon.RunPipeline('Calibration', '', 300);
vicon.RunPipeline('ExportC3D', '', 300);

vicon.SaveTrial(60);
end