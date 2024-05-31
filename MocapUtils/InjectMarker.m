
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
subject = 'DOE_NoE';%'DOE_KE'; %Make sure these correspond to exo conditions
studyName = 'DOE_TI'; % name of study
dir_C3D = 'C:\Users\rcasey9\Dropbox (GaTech)\DOE_Exos\Experiments\DOE_Task_Invariant_Protocol\Official_Collections\';
% dir_C3D = 'C:\Users\kdonahue8\Dropbox (GaTech)\DOE_Exos\Experiments\DOE Biomechanics Exo\Official_Collections\';
path = [dir_C3D studyName '_',subnumber,'_Processed_filled','\New Session\',Exo,'\'];

staticFiles = dir(fullfile(path,'*Static*.c3d'));
staticFile = staticFiles(1);
staticFile = erase(staticFile.name, '.c3d');


marker = 'LMANK';% marker = 'STRN';
markerA = 'LLANK';
markerB = 'LTIB_BOT';
markerC = 'LTIB_TOP';


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

markerV1 = 'LMKNE';
markerV2 = 'LLKNE';
markerV3 = 'LHEE';

mX = -2625 %591% -3262 for strn;
mY = 2250 %1120%2860 for strn;
mZ = 122 %-690%128 for strn;

vicon.OpenTrial([path staticFile], 20);

%EXTERNAL PACKAGES

%validate the input data
subjects = vicon.GetSubjectNames();
S = find(strcmp(subject, subjects), true);
if(numel(S) == 1)
    1
    markers = vicon.GetMarkerNames(subject);
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
      vicon.CreateModeledMarker( subject, marker );
      [data, exists] = vicon.GetModelOutput( subject, marker );
      framecount = vicon.GetFrameCount();
      for i=1:framecount
                exists(i) = true;
                data(1,i) = mX;
                data(2,i) = mY;
                data(3,i) = mZ;
      end
      M0 = [data(1,1);data(2,1);data(3,1)];
        %update the model output in the application
        vicon.SetModelOutput( subject, marker, data, exists ); 
     else
        error(['Invalid marker name ', markerA, ', ',markerB, ', ',markerV1, ', ',markerV2, ', ',markerV3 ', or ', markerC]);
    end   
else
    error(['Invalid subject name ', subject]);
end
vicon.SaveTrial(30);
Vicon_TRCExport(vicon,path,staticFile)


A0 = [AX0(1); AY0(1); AZ0(1)];
B0 = [BX0(1); BY0(1); BZ0(1)];
C0 = [CX0(1); CY0(1); CZ0(1)];

plot3([AX0(11) BX0(11) CX0(11) M0(1) MV1X(11) MV2X(11) MV3X(11)], [AY0(11) BY0(11) CY0(11) M0(2) MV1Y(11) MV2Y(11) MV3Y(11)], [AZ0(11) BZ0(11) CZ0(11) M0(3) MV1Z(11) MV2Z(11) MV3Z(11)],'o')
text([AX0(11) BX0(11) CX0(11) M0(1) MV1X(11) MV2X(11) MV3X(11)], [AY0(11) BY0(11) CY0(11) M0(2) MV1Y(11) MV2Y(11) MV3Y(11)], [AZ0(11) BZ0(11) CZ0(11) M0(3) MV1Z(11) MV2Z(11) MV3Z(11)], {markerA, markerB, markerC, marker, markerV1, markerV2, markerV3})
xlabel('x-axis')
ylabel('y-axis')
zlabel('z-axis')

%% SECTION 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Skip this section if you added your own marker in Section 2
vicon.OpenTrial([path staticFile], 20);

% EXTERNAL PACKAGES

% validate the input data
subjects = vicon.GetSubjectNames();
S = find(strcmp(subject, subjects), true);
if(numel(S) == 1)
    1
    markers = vicon.GetMarkerNames(subject);
    MA = find(strcmp(markerA, markers), true);
    MB = find(strcmp(markerB, markers), true);
    MC = find(strcmp(markerC, markers), true);
    M = find(strcmp(marker, markers), true);
    if ( (numel(MA) == 1) && (numel(MB) == 1) && (numel(MC) == 1) && (numel(M) == 1))
        2
      [AX0, AY0, AZ0, AE0] = vicon.GetTrajectory( subject, markerA );
      [BX0, BY0, BZ0, BE0] = vicon.GetTrajectory( subject, markerB );
      [CX0, CY0, CZ0, CE0] = vicon.GetTrajectory( subject, markerC );
      [MX, MY, MZ, ME] = vicon.GetTrajectory( subject, marker );

      M0 = [MX(1);MY(1);MZ(1)];
     else
        error(['Invalid marker name ', markerA, ', ',markerB, ', ',markerC, ', or ', marker]);
    end   
else
    error(['Invalid subject name ', subject]);
end
vicon.SaveTrial(30);
Vicon_TRCExport(vicon,path,staticFile)


A0 = [AX0(1); AY0(1); AZ0(1)];
B0 = [BX0(1); BY0(1); BZ0(1)];
C0 = [CX0(1); CY0(1); CZ0(1)];

%% SECTION 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c3dFiles = dir(fullfile(path,'*.c3d'));
for ff = length(c3dFiles):length(c3dFiles)
    if ~contains(c3dFiles(ff).name, 'static', 'IgnoreCase', true)
         baseName = erase(c3dFiles(ff).name,'.c3d');
         disp(baseName)
         vicon.OpenTrial([path baseName], 20)

        subjects = vicon.GetSubjectNames();
        S = find(strcmp(subject, subjects), true);
        if(numel(S) == 1)
            markers = vicon.GetMarkerNames(subject);
            MA = find(strcmp(markerA, markers), true);
            MB = find(strcmp(markerB, markers), true);
            MC = find(strcmp(markerC, markers), true);
            if ( (numel(MA) == 1) && (numel(MB) == 1) && (numel(MC) == 1))
        
              [AX1, AY1, AZ1, AE1] = vicon.GetTrajectory( subject, markerA );
              [BX1, BY1, BZ1, BE1] = vicon.GetTrajectory( subject, markerB );
              [CX1, CY1, CZ1, CE1] = vicon.GetTrajectory( subject, markerC );
        
              vicon.CreateModeledMarker( subject, marker );
              [data, exists] = vicon.GetModelOutput( subject, marker );
        
              framecount = vicon.GetFrameCount();
              for i=1:framecount
                        if (AE1(i) && BE1(i) && CE1(i))
                            exists(i) = true;
                            A1 = [AX1(i); AY1(i); AZ1(i)];
                            B1 = [BX1(i); BY1(i); BZ1(i)];
                            C1 = [CX1(i); CY1(i); CZ1(i)];
                            p = absor([A0 B0 C0],[A1 B1 C1]);
                            
                            M = p.R * M0 + p.t;

                            data(1,i) = M(1);
                            data(2,i) = M(2);
                            data(3,i) = M(3);

                        else
                            error(['Donor markers do not exist at frame ' i]);
                        end
              end
                
                % update the model output in the application
                vicon.SetModelOutput( subject, marker, data, exists ); 
             else
                error(['Invalid marker name ', markerA, ', ',markerB ', or ', markerC]);
            end   
        else
            error(['Invalid subject name ', subject]);
        end
        vicon.SaveTrial(30);
        Vicon_TRCExport(vicon,path,baseName)
    end


end


