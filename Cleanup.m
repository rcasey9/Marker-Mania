clc; clear all; close all;

tic
viconPath = 'C:\Program Files\Vicon\Nexus2.13\Nexus.exe';

filePath1 = 'C:\Users\rcasey9\Dropbox (GaTech)\DOE_Exos\Experiments\DOE_Task_Invariant_Protocol\Official_Collections2\TI';
filePath2 = '\Biomechanics_Data\DOE_TIA_';
filepath3 = '_PROCESSED\New Session';
folderList = {'01_V'};

for ii = 1:length(folderList)
sub = folderList{ii};
subNum = sub(1:2);
filePath = [filePath1 subNum filePath2 sub filepath3];
    markerSet = Get_MarkerSet(filePath, viconPath);
    Clean_Pass(markerSet, filePath);
    Endnote_Pass(filePath);
    %T10_relocate(markerSet, filePath);
end

toc
