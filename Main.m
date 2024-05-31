clc; clear; close all;
%% Specify path to your data

filePath1 = 'C:\Users\rcasey9\Dropbox (GaTech)\DOE_Exos\Experiments\DOE_Task_Invariant_Protocol\Official_Collections2\TI';
filePath2 = '\Biomechanics_Data\DOE_TIA_';
filepath3 = '_PROCESSED\New Session';

folderList = {'01_V'};

%% Specify your viconPath

tic
files = dir('C:\Program Files\Vicon');
for ii = length(files):1
    folder = files(ii).name;
    if contains(folder,'Nexus2*')
        break
    end
end

viconPath = ['C:\Program Files\Vicon\' folder '\Nexus.exe'];




%% Processing

for ii = 1:length(folderList)
sub = folderList{ii};
subNum = sub(1:2);
filePath = [filePath1 subNum filePath2 sub filepath3];


    markerSet = Get_MarkerSet(filePath, viconPath);
    First_Pass(markerSet, filePath, viconPath);
    Fourth_Pass(markerSet, filePath, viconPath);
    Fifth_Pass(markerSet, filePath, viconPath);
    Final_Pass(markerSet, filePath, viconPath);
    Move_Markerset_Files(filePath)
    Endnote_Pass(filePath)
end



toc
