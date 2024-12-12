%% imu_align_est

%This function used a two-step process to create rotation matrix representing the sensor's measured LCS 
% relative to that sensor's anatomical coordinate system (ie. "body")
% It uses the angular velocity during a flexion/extension movement to define the medial/lateral (y) axis, and it
%uses acceleration due to gravity to define the vertical (x) axis.

%Inputs: sensor=which sensor is being processed, ang_vel=angular velocity
%data from gyro, acc=linear acceleration data, points=start/stop points
%defined in IMU_Alignment Code

%anat=anatomical coordinate system
%meas=measured coordinate system

%Last edited by Anna Bailes 8/25/23

function output = imu_align_est_8_25(sensor, ang_vel,acc,points)
%% ASSIGN POINTS OF INTEREST

XStart = points(1);
XEnd = points(2);
YStart = points(3);
YEnd = points(4);

%% ESTIMATE VERTICAL AXIS (X) USING GRAVITY
  
acc_mean=mean(acc(XStart:XEnd,:)); %avg acc vector when person is stationary and upright
  
%FOR UPRIGHT SPINE SENSORS
    
if strcmpi('L5',sensor)
  
% XZ (rotation in sagittal plane) 

theta=atan(acc_mean(3)/acc_mean(1)); %using trig and geometry
thetadeg=theta*(180/pi);
Ry=[cos(theta),sin(theta);-sin(theta),cos(theta)]; %rotation matrix around y axis

%XY (rotation in frontal plane)
    
phi=atan(-acc_mean(2)/acc_mean(1)); %using trig and geometry
phideg=phi*(180/pi);
Rz=[cos(phi),-sin(phi);sin(phi),cos(phi)]; %rotation matrix around z axis

R_old=[Ry(1,1),0,Ry(1,2);0,1,0;Ry(2,1),0,Ry(2,2)]*[Rz(1,1),Rz(1,2),0;Rz(2,1),Rz(2,2),0;0,0,1]; %R_anat_meas
R=R_old'; %R_meas_anat

X = [R(1,1); R(2,1); R(3,1)]; % First column of rotation matrix

%FOR SPINE SENSORS TURNED DOWN
    
elseif strcmpi('T1',sensor) || strcmpi('L1',sensor)
  
% XZ (rotation in sagittal plane) 

theta=atan(acc_mean(3)/acc_mean(1)); %using trig and geometry
thetadeg=theta*(180/pi);
Ry=[cos(theta),sin(theta);-sin(theta),cos(theta)]; %rotation matrix around y axis

%XY (rotation in frontal plane)
    
phi=atan(acc_mean(2)/-acc_mean(1)); %using trig and geometry
phideg=phi*(180/pi);
Rz=[cos(phi),-sin(phi);sin(phi),cos(phi)]; %rotation matrix around z axis

R_old=[Ry(1,1),0,Ry(1,2);0,1,0;Ry(2,1),0,Ry(2,2)]*[Rz(1,1),Rz(1,2),0;Rz(2,1),Rz(2,2),0;0,0,1]; %R_anat_meas
R=R_old'; %R_meas_anat

X = [R(1,1); R(2,1); R(3,1)]; % First column of rotation matrix 

% FOR HIP SENSOR

elseif strcmpi('Hip',sensor)

%XY (rotation in sagittal plane) 
theta=atan(-acc_mean(2)/acc_mean(1)); %using trig and geometry
thetadeg=theta*(180/pi);
Rz=[cos(theta),-sin(theta);sin(theta),cos(theta)]; %rotation matrix around z axis

%XZ (rotation in frontal plane)
   
phi=atan(acc_mean(3)/acc_mean(1)); %using trig and geometry
phideg=phi*(180/pi);
Ry=[cos(phi),sin(phi);-sin(phi),cos(phi)]; %rotation matrix around y axis

R_old=[Rz(1,1),Rz(1,2),0;Rz(2,1),Rz(2,2),0;0,0,1]*[Ry(1,1),0,Ry(1,2);0,1,0;Ry(2,1),0,Ry(2,2)]; %R_anat_meas
R=R_old';

X = [R(1,1); R(2,1); R(3,1)]; %R_meas_anat
end
    
 %% ESTIMATE MEDIAL/LATERAL (Y) USING ANGULAR VELOCITY DURING FLEXION
 
AngleXy = sum(ang_vel(YStart:YEnd, 1));
AngleYy = sum(ang_vel(YStart:YEnd, 2));
AngleZy = sum(ang_vel(YStart:YEnd, 3));

MagY = norm([AngleXy, AngleYy, AngleZy]);

R12 = AngleXy / MagY;
R22 = AngleYy / MagY;
R32 = AngleZy / MagY;

Y = [R12; R22; R32]; %R_meas_anat

%% CALCULATE ANTERIOR/POSTERIOR AXIS BY TAKING CROSS PRODUCT
   
Zint = cross(X, Y);
Z = Zint / norm(Zint); %Third column of rotation matrix

% Take cross product again for orthogonality correction (assume x/gravity
% is most reliable vector)
Y=cross(Z,X);

output_old=[X,Y,Z]; %R_meas_anat
output = output_old'; %R_anat_meas
   
end


  
   
   
   
   
   
