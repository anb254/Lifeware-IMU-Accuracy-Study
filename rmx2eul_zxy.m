%% rmx2eul 

%This code decomposes a rotation matrix to derive the angles of rotation
%about the three primary axes of rotation. Order of rotation=zxy (ax rot, flex/ext,
%lat bend)

%Input: rotation matrix
%Output: Angles about z, then x, then y

function eul = rmx2eul(R)  
    eul(1) = atan2(-R(1,2), R(2,2)); %z
    eul(2)=asin(R(3,2)); %x
    eul(3) = atan2(-R(3, 1), R(3, 3)); %y 
end

