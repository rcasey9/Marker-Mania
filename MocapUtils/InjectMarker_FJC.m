
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


Exo = 'NoE';%'KE'; %Exo conditions for the subject {HW, KE, AE, NoE}
subject = 'DOE_TIA_2';%'DOE_KE'; %Make sure these correspond to exo conditions
studyName = 'DOE_TI'; % name of study
path = 'C:\Users\rcasey9\Dropbox (GaTech)\DOE_Exos\Experiments\DOE_Task_Invariant_Protocol\Official_Collections\TI02\Biomechanics_Data\DOE_TIA_02_PROCESSED\NEW Session\';

staticFiles = dir(fullfile(path,'*Static*.c3d'));
staticFileC3D = staticFiles(1);
staticFile = erase(staticFileC3D.name, '.c3d');

start_Frame = 330;

marker = 'T10';% marker = 'STRN';
markerA = 'T10_OFFSET';
markerB = 'LPSI';
markerC = 'RPSI';


%% SECTION 3 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Skip this section if you added your own marker in Section 2
vicon.OpenTrial([path staticFile], 20);

% EXTERNAL PACKAGES

% validate the input data
subjects = vicon.GetSubjectNames();
markers = vicon.GetMarkerNames(subject);
S = find(strcmp(subject, subjects), true);
    MA = find(strcmp(markerA, markers), true);
    MB = find(strcmp(markerB, markers), true);
    MC = find(strcmp(markerC, markers), true);
if(numel(S) == 1)
    1
    
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



A0 = [AX0(1); AY0(1); AZ0(1)];
B0 = [BX0(1); BY0(1); BZ0(1)];
C0 = [CX0(1); CY0(1); CZ0(1)];

%% SECTION 4 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

c3dFiles = dir(fullfile(path,'*FJC*.c3d'));

for ff = length(c3dFiles):length(c3dFiles)
    if ~contains(c3dFiles(ff).name, 'static')
         baseName = erase(c3dFiles(ff).name,'.c3d');
         disp(baseName)
         vicon.OpenTrial([path baseName], 20)
        markerStruct = Vicon.ExtractMarkers([path baseName '.c3d']);
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
        
            frames = length(AX1);
            markerStruct.(marker) = table;
            
            markerStruct.(marker).Header(markerStruct.(markerA).Header(:)') = [markerStruct.(markerA).Header(:)']';
            markerStruct.(marker).x(markerStruct.(markerA).Header(:)') = NaN;
            markerStruct.(marker).y(markerStruct.(markerA).Header(:)') = NaN;
            markerStruct.(marker).z(markerStruct.(markerA).Header(:)') = NaN;

              for i=markerStruct.(markerA).Header(:)'
                            
                        if (AE1(i) && BE1(i) && CE1(i))
                            

                            exists(i) = true;
                            A1 = [AX1(i); AY1(i); AZ1(i)];
                            B1 = [BX1(i); BY1(i); BZ1(i)];
                            C1 = [CX1(i); CY1(i); CZ1(i)];
                            p = absor([A0 B0 C0],[A1 B1 C1]);
                            
                            M = p.R * M0 + p.t;

                            markerStruct.(marker).x(i) = M(1);
                            markerStruct.(marker).y(i) = M(3);
                            markerStruct.(marker).z(i) = -M(2);

                        else
                            %warning(['Donor markers do not exist at frame ' i]);
                        end
              end
              
              try
                Vicon.markerstoC3D(markerStruct, [path baseName '.c3d'], [path baseName '.c3d']);
              catch
                  tbl = markerStruct.(marker);

                  markerStruct.(marker) = tbl;
                  Vicon.markerstoC3D(markerStruct, [path baseName '.c3d'], [path baseName '.c3d']);
              end
                % update the model output in the application
                
             else
               warning(['Invalid marker name ', markerA, ', ',markerB ', or ', markerC]);
            end   
        else
            warning(['Invalid subject name ', subject]);
        end
        
    end


end
