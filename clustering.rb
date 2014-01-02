#!/usr/bin/env ruby
module Clustering
  OPTICS_Point = Struct.new(:latitude, :longitude, :processed, :reachability, :core)
  DBSCAN_Point = Struct.new(:latitude, :longitude, :processed, :visited, :noise)
  Metadata = Struct.new(:latitude, :longitude, :radius, :count)
  Clusters = Struct.new(:clusters, :metadata)
  public
    def self.dbscan(d, eps, minpts)
      points = []
      d.each {|i| points.push(DBSCAN_Point.new(i[0],i[1],false,false))} # 0: lat 1: lon 2: visited 3: noise
      clusters = []
      points.each_with_index do |p,i|
        unless p.processed
          p.processed = true
          neighbors = regionquery(points,p,eps)
          if neighbors.length < minpts
            p.visited = true
          else
            clusters.push([])
            expandCluster(p, neighbors, clusters[-1], eps, minpts, points, clusters)
          end
        end
      end
      clusters = clusters.sort_by!(&:length).reverse

      metadata = getStats(clusters)

      Clusters.new(clusters, metadata)
    end

    def self.optics(d, eps, minpts, threshold)
      points = []
      ordered = []
      d.each {|i| points.push(OPTICS_Point.new(i[0],i[1],false,nil,nil))}
      until points.empty?
        p = points.pop()
        p.processed = true
        ordered.push(p)
        neighbors = regionquery(points,p,eps)
        unless coreDistance(p, neighbors, minpts).nil?
          seeds = [] #Eventually make this a priority queue
          update(neighbors, p, seeds)
          until seeds.empty?
            seeds.sort_by! { |i| i.reachability }.reverse!
            n = seeds.pop()
            points.delete(n)
            n.processed = true
            ordered.push(n)
            n_neighbors = regionquery(points,n,eps)
            unless coreDistance(n, n_neighbors, minpts).nil?
              update(n_neighbors, n, seeds)
            end
          end
        end
      end

      clusters = []
      separators = []
      ordered.each_with_index do |p_,i|
        if p_.reachability.nil? or p_.reachability > threshold
          separators.push(i)
        end
      end

      for i in 0...(separators.length-1)
        start = separators[i] + 1
        fin = separators[i+1]
        if (fin - start) > minpts
          clusters.push(ordered[start...fin])
        end
      end

      if not separators.empty? and (ordered.length - separators.last) > minpts
        clusters.push(ordered[(separators.last+1)..ordered.length])
      end

      clusters = clusters.sort_by!(&:length).reverse

      metadata = getStats(clusters)

      Clusters.new(clusters, metadata)
    end

  private
    def self.getStats(clusters)
      metadata = []
      clusters.each do |cluster|
        xbar = 0
        ybar = 0
        dbar = 0
        cluster.each do |point|
          xbar += point.latitude
          ybar += point.longitude
        end
        ybar /= cluster.length
        xbar /= cluster.length
        p=[xbar,ybar]
        dists = cluster.map { |i| Math.sqrt(distance2(p,i))}
        dbar = dists.inject(:+)/dists.length
        metadata.push(Metadata.new(xbar,ybar,dbar,dists.length))
      end
      metadata
    end

    def self.coreDistance(p, neighbors, minpts)
      if p.core.nil?
        if neighbors.length >= minpts-1
          dists = neighbors.map { |i| distance2(p,i) }.sort
          p.core = Math.sqrt(dists[minpts-2])
        end
      end
      return p.core
    end

    def self.update(neighbors, point, seeds)
      neighbors.each do |p|
        unless p.processed
          new_rd = [point.core,Math.sqrt(distance2(point,p))].max
          if p.reachability.nil?
            p.reachability = new_rd
            seeds.push(p)
          elsif new_rd < p.reachability
            p.reachability = new_rd
          end
        end
      end
    end

    def self.expandCluster(p, neighbors, c, eps, minpts, d, clusters)
      c.push(p)
      neighbors.each do |point|
        unless point.processed
          point.processed = true
          newneighbors = regionquery(d,point,eps)
          if newneighbors.length >= minpts
            neighbors.concat(newneighbors)
          end
        end
        unless incluster(point, clusters)
          c.push(point)
        end
      end
    end

    def self.incluster(p, clusters)
      clusters.each { |c| c.each { |d| return true if d == p}}
      return false
    end

    # O(n^2) for now
    def self.regionquery(d, p, eps)
      nearbypoints = []
      d.each {|point| nearbypoints.push(point) if nearby(p,point,eps)}
      return nearbypoints
    end

    def self.distance2(p1,p2)
      return ((p1[0]-p2[0])**2 + (p1[1]-p2[1])**2)
    end

    def self.nearby(p1,p2,eps)
       return distance2(p1, p2) < eps*eps
    end
end
