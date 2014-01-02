function [ coords ] = gengeodata( num, clusters, min0, max0, min1, max1, min2, max2, filename )
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
d = zeros(num, 2);
coords = zeros(clusters,3);
for i = 1:clusters
    coords(i,1) = rand() * (max1-min1) + min1;
    coords(i,2) = rand() * (max2-min2) + min2;
    coords(i,3) = rand() * (max0-min0) + min0;
    coords(i,:);
    for j = 1:num/clusters
        d((i-1)*num/clusters+j,1) = coords(i,1) + coords(i,3)*randn();
        d((i-1)*num/clusters+j,2) = coords(i,2) + coords(i,3)*randn();
    end
end
csvwrite(filename,d);
end
