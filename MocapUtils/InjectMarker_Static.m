
%author: Ryan Casey
%contact info: rcasey9@gatech.edu

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%This code will create a modelled marker from 3 other markers, similar to rigid body
%filling. It can be used in instances when a marker is absent from an
%entire condition of data collection. This code should only be run on
%otherwise fully-processed Vicon data.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% HOW TO USE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Sections are designed to be run sequentially 1 -> 4. Follow the
%Instructions in the comments at the beginning of each section

%% SECTION 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Required Setup: 
% 1) mocap tools toolbox added to matlab path. 
% 2) Vicon Matlab SDK added to matlab path
% 3) Folder containing all of the trials you want to add a marker to as
% well as the static trial associated with those trials (all trials fully
% processed already)
% 4) Have the folder from 3) open in Vicon.

%Relevant Variables:
%path: absolue path to the folder with all of your data in it
%subject: name of the Vicon subject being used in this data
%marker: The marker you want to add
%markerA,markerB,markerC: The donor markers you want to use to backfill
%the modelled marker. (same rules as rigid body filling apply)


close all; clear; clc;
vicon = ViconNexus();

subnumber = '01';%'07';%'04'; % subject number as two digit string

Exo = 'NoE';%'KE'; %Exo conditions for the subject {HW, KE, AE, NoE}
subject = 'DOE_TI';%'DOE_KE'; %Make sure these correspond to exo conditions
studyName = 'DOE_TI'; % name of study
path = 'C:\Users\rcasey9\Dropbox (GaTech)\DOE_Exos\Experiments\DOE_Task_Invariant_Protocol\Official_Collections\TI07\Biomechanics_Data\DOE_TIA_07_PROCESSED\New Session\';

staticFiles = dir(fullfile(path,'*V_static*.c3d'));
staticFileC3D = staticFiles(1);
staticFile = erase(staticFileC3D.name, '.c3d');


marker = 'LFRM';% marker = 'STRN';
markerA = 'LMELB';
markerB = 'LLELB';
markerC = 'LRAD';


%% SECTION 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Skip this section if your marker is present in the static trial

%This section can be run over and over again until you finalize the
%positioning of the marker you want to add. You will need to delete the
%modelled marker you have created every time you re-run Section 2.

%A 3d plot of all the markers will appear every time this section is run.
%Use this plot for coarse adjustments in marker placement. For finer
%adjustments, the visualizer wihin Vicon is much more useful.

%relevant variables:
%markerV1,markerV2,markerV3: more markers to help with visualization, just
%choose markers other than markers A,B,C
%mX,mY,mZ: X,Y,Z coordinates of the marker you want to add.

markerV1 = 'LULN';
markerV2 = 'LSHO';
markerV3 = 'LUPA';

mX = -2940;
mY = 1070;
mZ = -2240;
vicon.OpenTrial([path staticFile], 20);

%EXTERNAL PACKAGES

%validate the input data
subjects = vicon.GetSubjectNames();
S = find(strcmp(subject, subjects), true);
if(numel(S) == 1)
    1
    markers = vicon.GetMarkerNames(subject);
    markerStruct = Vicon.ExtractMarkers([path staticFileC3D.name]);
    MA = find(strcmp(markerA, markers), true);
    MB = find(strcmp(markerB, markers), true);
    MC = find(strcmp(markerC, markers), true);
    MV1 = find(strcmp(markerV1, markers), true);
    MV2 = find(strcmp(markerV2, markers), true);
    MV3 = find(strcmp(markerV3, markers), true);
    if ( (numel(MA) == 1) && (numel(MB) == 1) && (numel(MC) == 1) && (numel(MV1) == 1) && (numel(MV2) == 1) && (numel(MV3) == 1))
        2
      [AX0, AY0, AZ0, AE0] = vicon.GetTrajectory( subject, markerA );
      [BX0, BY0, BZ0, BE0] = vicon.GetTrajectory( subject, markerB );
      [CX0, CY0, CZ0, CE0] = vicon.GetTrajectory( subject, markerC );
      [MV1X, MV1Y, MV1Z, MV1E] = vicon.GetTrajectory( subject, markerV1 );
      [MV2X, MV2Y, MV2Z, MV2E] = vicon.GetTrajectory( subject, markerV2 );
      [MV3X, MV3Y, MV3Z, MV3E] = vicon.GetTrajectory( subject, markerV3 );
      
        %update the model output in the application
        markerStruct.(marker) = table;
        for ii = 1:length(markerStruct.(markerA).Header(:)')
        markerStruct.(marker).Header(ii) = markerStruct.(markerA).Header(ii);
            markerStruct.(marker).x(ii) = mX;
            markerStruct.(marker).y(ii) = mY;
            markerStruct.(marker).z(ii) = mZ;
        end
        % marks = fieldnames(markerStruct);
        % flds = fieldnames(markerStruct.C7);
        % for ff = 1:length(marks)
        %     mark = marks{ff}
        %     markerStruct.(mark).Header(2) =  markerStruct.(mark).Header(1)+1;
        %     for jj = 2:4
        %         fld = flds{jj}
        %         markerStruct.(mark).(fld)(2) =  markerStruct.(mark).(fld)(1);
        %     end
        % 
        % 
        % end
        
            Vicon.markerstoC3D(markerStruct, [path staticFileC3D.name], [path staticFile '_filled.c3d']);
     else
        error(['Invalid marker name ', markerA, ', ',markerB, ', ',markerV1, ', ',markerV2, ', ',markerV3 ', or ', markerC]);
    end   
else
    error(['Invalid subject name ', subject]);
end

%Vicon_TRCExport(vicon,path,staticFile)


A0 = [AX0(1); AY0(1); AZ0(1)];
B0 = [BX0(1); BY0(1); BZ0(1)];
C0 = [CX0(1); CY0(1); CZ0(1)];
Frame = markerStruct.(markerA).Header(ii);
plot3([AX0(Frame) BX0(Frame) CX0(Frame) mX MV1X(Frame) MV2X(Frame) MV3X(Frame)], [AZ0(Frame) BZ0(Frame) CZ0(Frame) mY MV1Z(Frame) MV2Z(Frame) MV3Z(Frame)], -[AY0(Frame) BY0(Frame) CY0(Frame) -mZ MV1Y(Frame) MV2Y(Frame) MV3Y(Frame)],'o')
text([AX0(Frame) BX0(Frame) CX0(Frame) mX MV1X(Frame) MV2X(Frame) MV3X(Frame)], [AZ0(Frame) BZ0(Frame) CZ0(Frame) mY MV1Z(Frame) MV2Z(Frame) MV3Z(Frame)], -[AY0(Frame) BY0(Frame) CY0(Frame) -mZ MV1Y(Frame) MV2Y(Frame) MV3Y(Frame)], {markerA, markerB, markerC, marker, markerV1, markerV2, markerV3})
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

