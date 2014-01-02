% this line can be commeted out if the absolute paths are used
[folder, name, ext] = fileparts(mfilename('fullpath'));
cd(folder);

% Set debug to 1 to view the size of the neighbor radius (epsilon) on the graph
debug=0;
epsilon=1.0;

% Generate the data - param values are described in gengeodata.m
data=gengeodata(800,10,1,2,-10,10,-10,10,'geopoints.csv');

% Run the clustering in ruby and get the data out
gp=csvread('geopoints.csv');
system('./test_clustering.rb');

% Assignment of data points to clusters
gcd=csvread('geoclustersdata.csv');

% The clusters themselves
gc=csvread('geoclusters.csv');

point_clusternum=gc(:,1);
point_latitude=gc(:,2);
point_longitude=gc(:,3);

cluster_clusternum=gcd(:,1);
cluster_latitude=gcd(:,2);
cluster_longitude=gcd(:,3);
cluster_radius=gcd(:,4);
cluster_count=gcd(:,5);

circlesize = 100;
colormap(hsv(length(gcd)));
clf;
hold on;

% Plot the points
scatter(point_latitude, point_longitude, circlesize, point_clusternum, 'filled');

if debug
  scatter(point_latitude, point_longitude, (50*50*epsilon*epsilon*pi), point_clusternum);
end

% Plot the locations and sizes of the generated clusters
scatter(data(:,1), data(:,2), (600*4*data(:,3).*data(:,3)),[0 0 0]);

% Plot the determined clusters
scatter(cluster_latitude, cluster_longitude, 600*4*cluster_radius.*cluster_radius, cluster_clusternum,'LineWidth',4);
hold off;
