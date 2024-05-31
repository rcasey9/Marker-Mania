%%  GAP FILLING AND NEW C3D GENERATION FOR LIFTING trials

function Marker_Checker(markerSet,filename,path,finalCheck)
staticFiles = dir(fullfile(path,'*Static*.c3d'));
staticFile = staticFiles(1);
staticFile = staticFile.name;


staticFile = [path '\' staticFile];
staticStruct = Vicon.ExtractMarkers(staticFile);
clusterNames = fieldnames(markerSet);
for cc = 1:length(clusterNames)
    cluster = {};
    names = fieldnames(markerSet.(clusterNames{cc}));
    for cl = 1:length(names)
    cluster{cl} = names{cl};
    end
    for qq = 1:length(cluster)
        currentmarker= cluster{qq};
        staticCoords(cc,1:3,qq)= [staticStruct.(cluster{qq}).x(1),staticStruct.(cluster{qq}).y(1),staticStruct.(cluster{qq}).z(1)]';
    end
end
%%
c3dFile = [filename '.c3d'];
c3dFileName = erase(filename,[path '\Working\']);
    if contains(c3dFile,'filled')
        unlabelled = 0;

                    markerStruct = Vicon.ExtractMarkers(c3dFile);
                    for cc = 1:length(clusterNames)
                        clusterNames{cc};
                    cluster = {};
                    names = fieldnames(markerSet.(clusterNames{cc}));
                    for cl = 1:length(names)
                    cluster{cl} = names{cl};
                    end
                    clusterSize = size(cluster);
                    absoluteMarkerErrors = [];
                    for ff = 1:length(markerStruct.(cluster{1}).Header)
                        markerNames = {};
                        
                        relativeMarkerErrors = [];
                        attempts = 0;
                        fixed = false;
                        
                        for qq = 1:clusterSize(2)
                            markerNames{qq} = cluster{qq};
                            clusterInds = 1:clusterSize(2);
                            clusterInds(qq) = [];
                            previoudsMarkerCoords = [];
                            markerCoords = [];
                            staticCoordsRef = [];
                            for ll = 1:length(clusterInds)
                                ind = clusterInds(ll);
                                
                                markerCoords(1:3,ll) = [markerStruct.(cluster{ind}).x(ff), markerStruct.(cluster{ind}).y(ff), markerStruct.(cluster{ind}).z(ff)];
                                staticCoordsRef(1:3,ll) = staticCoords(cc,1:3,ind);
                                
                            

                            end
                            if ~any(isnan(markerCoords)) & ~any(isnan(staticCoordsRef))
                            p = absor([staticCoordsRef],[markerCoords]);
                            M = p.R * [staticCoords(cc,1,qq);staticCoords(cc,2,qq);staticCoords(cc,3,qq);] + p.t;
                            absoluteMarkerErrors(ff,qq) = sqrt((markerStruct.(cluster{qq}).x(ff)-M(1)).^2 + (markerStruct.(cluster{qq}).y(ff)-M(2)).^2 + (markerStruct.(cluster{qq}).z(ff)-M(3)).^2);
                            else
                            absoluteMarkerErrors(ff,qq) = 0;   
                            end
                        end
                    end
                    unlabelLocations = absoluteMarkerErrors .* 0;
                        for pp = 1:length(absoluteMarkerErrors)
  
                            
                            frameErrors = absoluteMarkerErrors(pp,:);
                            maxError = max(frameErrors);
                            maxInd = find(frameErrors == maxError);
                            maxInd = maxInd(1);
                            errorThreshold = 130;
                            if maxError > errorThreshold
                                location = find(frameErrors == maxError);
                                startInd = pp - 30;
                                endInd = pp +30;
                                if startInd < 1
                                    startInd = 1;
                                end
                                if endInd > length(absoluteMarkerErrors)
                                    endInd = length(absoluteMarkerErrors);
                                end
                                if ~finalCheck
                                unlabelLocations(startInd:endInd,location) = 1;
                                
                                end
                                unlabelled = unlabelled + 1;
                            end
                        end
                        for pp = 1:length(unlabelLocations)
                            sumMarkers = 0;
                            for qq = 1:length(clusterInds)
                                if unlabelLocations(pp,qq) == 1
                                    if sumMarkers > 0
                                        unlabelLocations(pp,qq) = 0;
                                    end
                                    sumMarkers = sumMarkers +1;
                                end 
                            end
                        end
                        for ff = 1:length(unlabelLocations)
                            for qq = 1:length(clusterInds)
                                if unlabelLocations(ff,qq) == 1
                                    markerStruct.(cluster{qq}).x(ff) = NaN;
                                    markerStruct.(cluster{qq}).y(ff) = NaN;
                                    markerStruct.(cluster{qq}).z(ff) = NaN;
                                end  
                            end
                        end
                        
                        
                        
                    end
                    disp([num2str(unlabelled) ' total instances of markers out of place across all frames'])
                    disp(['the allowable limit is ' num2str(round(ff/.4))])
                  
                        disp('    Writing new C3D file...')
                        if unlabelled > ff/.4
                            checkedC3D = ([c3dFile(1:length(c3dFile)-11),'.c3d']);
                            Vicon.markerstoC3D(markerStruct, c3dFile, checkedC3D);
                            pause(3)
                        else
                            checkedC3D = ([path '\Finished\' c3dFileName]);
                            Vicon.markerstoC3D(markerStruct, c3dFile, checkedC3D);
                            delete(c3dFile);
                            delete([path '\' c3dFileName(1:length(c3dFileName)-7),'.c3d'])
                            pause(3)
                        end

                    end


end


