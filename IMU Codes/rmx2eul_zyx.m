%% rmx2eul 

%This code decomposes a rotation matrix to derive the angles of rotation
%about the three primary axes of rotation. Order of rotation=zyx (latbend, flex/ext,
%axrot)

%Input: rotation matrix
%Output: Angles about z, then y, then x

function eul = rmx2eul(R)  
    eul(1) = atan2(R(2,1), R(1,1)); %z
    eul(2)=asin(-R(3,1)); %y
    eul(3) = atan2(R(3, 2), R(3, 3)); %x 
end

