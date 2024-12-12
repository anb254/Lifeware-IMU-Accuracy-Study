%% rmx2eul 

%This code decomposes a rotation matrix to derive the angles of rotation
%about the three primary axes of rotation. Order of rotation=xyz (rot,
%flex/ext, lat bend)

%Input: rotation matrix
%Output: Angles about x, then y, then z

function eul = rmx2eul(R)  
    eul(1) = atan2(-R(2,3), R(3,3)); %z
    eul(2)=asin(R(1,3)); %y
    eul(3) = atan2(-R(1,2), R(1,1)); %x 
end

