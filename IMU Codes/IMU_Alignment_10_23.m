%% IMU ALIGNMENT 

%This code creates the alignment matrices for the Lifeware IMU sensors. It is used for 4 sensors attached to T1/L1/L5/Hip. 

%Input=.mat file saved from raw IMU data load process
%Ouput=Rotation matrices for that represents a sensor's measured coordinate
%system wrt its anatomical coordinate system.

%Last edited by Anna Bailes 8/14/23


%% LOAD IMU DATA FILES

clc; clear all; close all

subject=input('Enter Subject_ID: ','s');
folder= strcat('P:\Lifeware Accuracy Study\Fall 23 Analysis\IMU Data\',subject,'\');
mkdir(folder)

%% SELECT WHICH SENSOR WAS USED

trial=uigetfile(strcat('P:\Lifeware Accuracy Study\Fall 23 Analysis\Raw Data Load\',subject,'\'),'.mat');
addpath(strcat('P:\Lifeware Accuracy Study\Fall 23 Analysis\Raw Data Load\',subject,'\'));
working=importdata(trial);
%%
ask = input('Calibrate sensor (T1/L1/L5/Hip) ','s');

if strcmpi('T1',ask)
    ang_vel=working.T1.gyro(:, :);
    acc=working.T1.acc(:, :);
elseif strcmpi('L1',ask)
    ang_vel=working.L1.gyro(:, :);
    acc=working.L1.acc(:, :);
elseif strcmpi('L5',ask)
    ang_vel=working.L5.gyro(:, :);
    acc=working.L5.acc(:, :);
elseif strcmpi('Hip',ask)
    ang_vel=working.Hip.gyro(:, :);
    acc=working.Hip.acc(:, :);
end

%% USE GYROSCOPE TO DETERMINE FLEX/EXT AND VERTICAL AXES
start_idx=1;
end_idx=4000; %This will usually get first alignment procedure

figure(2)
figure('units', 'normalized','outerposition', [0 0 1 1])
title('Velocity about an anatomical axis')
plot(ang_vel(start_idx:end_idx,:)) 
xlabel('Sample points')
ylabel('Angular velocity (rad/s)')
legend('AxRot', 'Flex/Ext', 'LatBend') 
grid on

prompt = 'Enter amount of repetitions:';
dlg_titles = 'Number of rotations';
rot_num = cell2mat(inputdlg(prompt, dlg_titles));
rot_num = str2double(rot_num);

%Choose positive rotations for all functional movements in order to create
%anatomical to measured coordinate system that corresponds to directionality of GCS

        msg = msgbox('Select positive rotations for Flexion'); %positive rotations correspond to extension in +y direction
        pause(0.5)
        delete(msg);
        [selected_pts_1, ~] = ginput(2 * rot_num);

        msg = msgbox('Select points where angular velocity equals 0');
        pause(0.5)
        delete(msg);
        [selected_pts_2, ~] = ginput(2);
        close all


%This saves the start/end point selected for each rotation
y_start = (start_idx-1) + floor(selected_pts_1(1:2:end - 1));
y_end = (start_idx-1) + floor(selected_pts_1(2:2:end));
x_start = (start_idx-1) + floor(selected_pts_2(1));
x_end = (start_idx-1) + floor(selected_pts_2(2));
%% CALL ALIGNMENT FUNCTION

%Calls function to derive alignment matrix
%(R_anat_meas)

event_pts = zeros(rot_num, 4);
align_est = zeros(3, 3, rot_num);

for i = 1:rot_num
    event_pts(i, :) = [x_start, x_end, y_start(i), y_end(i)]; %call endpts from previous step using gyro data
    align_est(:, :, i) = imu_align_est_8_25(ask, ang_vel, acc, event_pts(i, :));
end

%% SAVE FILES

%R_anat_meas
if strcmpi('T1',ask)
    align_T1 = align_est;  
    save(strcat(folder, subject, '_align2_T1.mat'), 'align_T1')
elseif strcmpi('L1',ask)
    align_L1 = align_est;  
    save(strcat(folder, subject, '_align2_L1.mat'), 'align_L1')
elseif strcmpi('L5',ask)
    align_L5 = align_est;  
    save(strcat(folder, subject, '_align2_L5.mat'), 'align_L5')
elseif strcmpi('Hip',ask)
    align_Hip = align_est;  
    save(strcat(folder, subject, '_align2_Hip.mat'), 'align_Hip')
end
