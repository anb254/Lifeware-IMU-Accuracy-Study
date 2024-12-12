%% rmx2eul 

%This code decomposes a rotation matrix to derive the angles of rotation
%about the three primary axes of rotation. Order of rotation=yxz (flex/ext,
%latbend, ax rot)

%Input: rotation matrix
%Output: Angles about y, then z, then x

function eul = rmx2eul(R)  
    eul(1) = atan2(-R(3,1), R(1,1)); %y
    eul(2)=asin(R(2,1)); %z
    eul(3) = atan2(-R(2,3), R(2,2)); %x 
end

