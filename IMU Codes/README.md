Load raw data from IMU outputs, which includes a structure with fields including linear acceleration and gyroscope data.
Run IMU_Alignment_10_23.m, which calls imu_align_est_8_25.m to get the R_body_IMUlocal rotation matrices for each sensor.
Run Accuracy_IMU_Dynamic_9_7.m, which derives ROM for each segment and calls the following three additional functions to derive Euler angles based on different orders of decomposition: rmx2eul_xyz, rmx2eul_yzx, rmx2eul_zyx
