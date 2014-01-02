#!/usr/bin/env ruby

require 'csv'
require './clustering'
dbscan = false
points=CSV.read(File.expand_path('geopoints.csv'), converters: :all)
min = 3
eps = 1.00
threshold = 1
cdata = nil
if dbscan
    clustering = Clustering.dbscan(points, eps, min)
else
    clustering = Clustering.optics(points, eps, min, threshold)
end
clusters = clustering.clusters
cdata = clustering.metadata

CSV.open(File.expand_path('geoclusters.csv'),'w') do |csv|
    points.each do |p|
        csv << [0,p[0],p[1]] if p[3]
    end
    clusters.each_with_index do |cluster,i|
        cluster.each do |p|
            csv << [i+1,p[0],p[1]]
        end
    end
end
CSV.open(File.expand_path('geoclustersdata.csv'),'w') do |csv|
    cdata.each_with_index do |c,i|
        csv << [i+1, c.latitude, c.longitude, c.radius, c.count]
    end
end
