%% rmx2eul 

%This code decomposes a rotation matrix to derive the angles of rotation
%about the three primary axes of rotation. Order of rotation=yxz (lat bend,
%flex/ext, axrot

%Input: rotation matrix
%Output: Angles about y, then x, then z

function eul = rmx2eul(R)  
    eul(1) = atan2(R(1,3), R(3,3)); %y
    eul(2)=asin(-R(2,3)); %x
    eul(3) = atan2(R(2, 1), R(2, 2)); %z 
end

