clc; close all; clear;

directory = pwd;

addpath([directory '\MocapUtils'])
addpath([directory '\MocapUtils'])


files = dir('C:\Program Files\Vicon');
for ii = length(files):-1:1
    folder = files(ii).name;
    if contains(folder,'Nexus2')
        ViconFolder = folder;
        break
    end
end
addpath(['C:\Program Files\Vicon\' ViconFolder '\SDK\MATLAB'])


files = dir('Pipelines');
for ii = length(files):-1:1
    file = files(ii).name;
    if contains(file,'.Pipeline')
        copyfile([directory '\Pipelines\' file], ['C:\Users\Public\Documents\Vicon\Nexus2.x\Configurations\Pipelines\' file])
    end
end