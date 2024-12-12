%% VICON ALIGN EST%%

%This function used a two-step process to create rotation matrix representing the sensor's measured LCS 
% relative to that sensor's anatomical coordinate system (ie. "body")
% It uses the angular velocity during a flexion/extension movement to define the medial/lateral (x) axis, and it
%uses position of the markers wrt gravity to define the vertical (z) axis.

%anat=anatomical coordinate system
%meas=measured coordinate system

%Last edited by Anna Bailes 12/12/23

function  output = align_est_8_25(data, RG_V,points)
%% DEFINE START/STOP OF FUNCTIONAL MOVEMENT CALIBRATION

    ZStart = points(1); % vertical 
    ZEnd = points(2);
    XStart = points(3); % flex/ext
    XEnd = points(4); 


%% ESTIMATE MEDIAL/LATERAL (X) USING ANGULAR VELOCITY DURING FLEXION

    AngleXX = sum(data(XStart:XEnd, 1));
    AngleXY = sum(data(XStart:XEnd, 2));
    AngleXZ = sum(data(XStart:XEnd, 3));
    
    MagX = norm([AngleXX, AngleXY, AngleXZ]);
    
    R11 = AngleXX / MagX;
    R21 = AngleXY / MagX;
    R31 = AngleXZ / MagX;
    
    X = [R11; R21; R31]; %R_meas_anat, 1st column of rotation matrix
    
 %% ESTIMATE VERTICAL AXIS (Z) USING MARKERS WRT GRAVITY

RG_V_still=RG_V(:,:,round(ZStart):round(ZEnd)); %R_anat_meas

avg=[]; %take average rotation matrix during still period
for j=1:3
for i=1:3
    avg(i,j)=mean([RG_V_still(i,j,:)]);
end
end

RV_G_still=avg'; %R_meas_anat
Z=RV_G_still(:,3)/norm(RV_G_still(:,3)); %R_meas_anat, 3rd column of rotation matrix

%% CALCULATE ANTERIOR/POSTERIOR AXIS BY TAKING CROSS PRODUCT

Yint = cross(Z, X);
Y = Yint / norm(Yint); %R_meas_anat, 2nd column of rotation matrix

% Take cross product again for orthogonality correction (assume z/gravity is most reliable vector)
X=cross(Y,Z);

output_old= [X,Y,Z]; %R_meas_anat
output=output_old'; %R_anat_meas
end

