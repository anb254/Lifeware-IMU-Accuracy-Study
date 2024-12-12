%% VICON ALIGNMENT

%This code creates the alignment matrices for the Vicon motion tracking
%system. It is used for 4 sensors attached to T1/L1/L5/Hip. 

%Input= .txt file from Vicon that includes marker positions for each of
%3 reflective markers attached to each sensor. 
%Output= is a rotation matrix that represents a sensor's measured coordinate system wrt its anatomical coordinate system.

%Adapted from Marcus Allen and William Clark's Lab.
%Last updated 8/25/23 by Anna Bailes

clc; clear; close all;

%% SELECT SUBJECT AND ALIGNMENT TRIAL
subject = input('Enter Subject ID: ','s');
folder= strcat('P:\Lifeware Accuracy Study\Vicon Codes\Fall 23 Analysis\',subject,'\');
mkdir(folder)

cd(strcat('P:\Lifeware Accuracy Study\Data\LW_',subject,'\Session1\'));
data_folder=strcat('P:\Lifeware Accuracy Study\Data\LW',subject,'\Session1\');
trial_txt = uigetfile('.txt', data_folder,'Select Alignment Trial');

cd('P:\Lifeware Accuracy Study\Vicon Codes\Fall 23 Analysis');
addpath(strcat('P:\Lifeware Accuracy Study\Data\LW_',subject,'\Session1\'));
txt2mat(trial_txt)  %Copyrighted function by Arash Mahboobin that is used to save raw marker data to as variables in Matlab
matfile=strcat(trial_txt(1:end-4),'.mat');
load(matfile)
status=movefile(matfile,folder);

[b, a] = lpfilter; % create low-pass filter by calling function lpfilter
    
%% CREATE MEASURED LCS USING MARKERS

%Names of markers listed below

ask = input('Calibrate sensor (T1/L1/L5/Hip): ','s');
while 1
    if strcmpi('T1',ask)  %vector and marker positions as of 2/12/2021.
        vector1 = AL-AR; 
        vector2 = AT-AR;
        break
    elseif strcmpi('L1',ask)
        vector1 = BL-BR;
        vector2 = BT-BR;
        break
    elseif strcmpi('L5',ask)
        vector1 = CL-CR;
        vector2= CT-CR;
        break
    elseif strcmpi('Hip',ask)
        vector1 = DB-DF;
        vector2 = DT-DF;
        break
    else
        ask = input('Calibrate sensor (T1/L1/L5/Hip): ','s');
    end
end

%Calculate double cross product of previously calculated vectors to create
%orthogonal coordinate systems corresponding to x, y, z of measured Vicon
%markers. X is to the right, Y is forward, Z is up. This corresponds with
%directionality of lab/global coordinate system.

data_len=length(time); %Vtime is from txt2mat code

for i=1:data_len
    vector3(i,:) = cross(vector1(i,:),vector2(i,:));
    vector4(i,:) = cross(vector3(i,:),vector1(i,:));
end

while 1 %T1 and L1 placed upside down due to clothing/skin artifact

    if strcmpi('T1',ask)
        for i=1:data_len
            vector_x(i,:)=vector1(i,:)/norm(vector1(i,:));
            vector_y(i,:)=vector3(i,:)/norm(vector3(i,:));
            vector_z(i,:)=-vector4(i,:)/norm(vector4(i,:));
        end
        break
    elseif strcmpi('L1',ask)
        for i=1:data_len
            vector_x(i,:)=vector1(i,:)/norm(vector1(i,:));
            vector_y(i,:)=vector3(i,:)/norm(vector3(i,:));
            vector_z(i,:)=-vector4(i,:)/norm(vector4(i,:));
        end
        break
    elseif strcmpi('L5',ask)
        for i=1:data_len
            vector_x(i,:)=-vector1(i,:)/norm(vector1(i,:));
            vector_y(i,:)=vector3(i,:)/norm(vector3(i,:));
            vector_z(i,:)=vector4(i,:)/norm(vector4(i,:));
        end
        break
    elseif strcmpi('Hip',ask)
        for i=1:data_len
            vector_x(i,:)=-vector3(i,:)/norm(vector3(i,:));
            vector_y(i,:)=-vector1(i,:)/norm(vector1(i,:));
            vector_z(i,:)=vector4(i,:)/norm(vector4(i,:));
        end
        break
    end
end


for i=1:data_len
    RG_V(:, :, i) = [vector_x(i,:)', vector_y(i, :)', vector_z(i,:)'];
    euler(i,:)=rmx2eul_xyz(RG_V(:,:,i)); %Calculate euler angles from rotation matrix, prioritize flex/ext axis
end

index=find(~isnan(euler(:,1)),1); %find first non-NaN value
euler=euler(index:end,:);
        
%% CALCULATE ANGULAR VELOCITY %%

newtime = time(index:end);
ang_vel = [];

for i = 1:3
    if isempty(find(diff(euler(:, i)) > pi)) == 0 %if wrapping occurs (angle jumps over 180 deg.)
        euler(:, i) = unwrap(euler(:, i));
    end
    ang_vel(:, i) = diff(euler(:, i)) ./ diff(newtime);
    ang_vel(:, i) = filtfilt(b, a, ang_vel(:, i)); %filter angular velocity
end
        
%% PLOT ANGULAR VELOCITY %%
%Prompted to select points that correspond to start/end of each rotation.
        
figure('units', 'normalized','outerposition', [0 0 1 1])
title('Velocity about an anatomical axis')
plot(ang_vel)
xlabel('Sample points')
ylabel('Angular velocity (rad/s)')
legend('Flex./Ext.', 'Lat. Bend', 'Ax. Rot.')
grid on

while 1
    msg = msgbox('Select positive rotations for Flexion'); %positive rotations correspond to extension in +y direction
    pause(0.5)
    delete(msg);
    [selected_pts_1, ~] = ginput(2);

    msg = msgbox('Select points where angular velocity equals 0');
    pause(0.5)
    delete(msg);
    [selected_pts_2, ~] = ginput(2);
    close all
    break
end

%This saves the start/end point
x_start = floor(selected_pts_1(1));
x_end = floor(selected_pts_1(2));
z_start = floor(selected_pts_2(1));
z_end = floor(selected_pts_2(2));
        
%% CALL ALIGNMENT FUNCTION
%Calls the align_matrix_est function to derive alignment matrix
%(R_anat_meas)

event_pts = [z_start, z_end, x_start, x_end];
align_est = vicon_align_est_8_25(ang_vel, RG_V,event_pts);
    
%% SAVE FILES

%R_anat_meas
if strcmpi('T1',ask)
    align_T1 = align_est;  
    save(strcat(folder,subject,'_align_T1_new.mat'), 'align_T1')
elseif strcmpi('L1',ask)
    align_L1 = align_est;  
    save(strcat(folder,subject,'_align_L1_new.mat'), 'align_L1')
elseif strcmpi('L5',ask)
    align_L5 = align_est; 
    save(strcat(folder,subject,'_align_L5_new.mat'), 'align_L5')
elseif strcmpi('Hip',ask)
    align_Hip = align_est;  
    save(strcat(folder,subject,'_align_Hip_new.mat'), 'align_Hip')
end

   