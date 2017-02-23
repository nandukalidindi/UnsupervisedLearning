# *****************************************************************
# NOTE: Please place this file in the same folder as the cluster files
# *****************************************************************

class SilhouetteCoefficient
  class << self
    # Internal: Calculates the cluster dissimilarity measure
    #
    # Return: Float
    #
    # Examples
    #   silhouette_coefficient(cluster1, list_of_clusters)
    def silhouette_coefficient(cluster, clusters)
      @clusters = clusters
      silhouttes = []
      distance_array = []
      cluster.each do |point1|
        a1 = a1(cluster, point1)
        b1 = b1(cluster, point1)
        s1 = (b1 - a1)/([a1, b1].max)
        silhouttes << s1
      end
      (silhouttes.inject(:+) / silhouttes.size)
    end

    # Internal: Calculates the cluster dissimilarity mean for each point in the cluster
    #
    # Return: Float
    #
    # Examples
    #   a1(cluster1, point)
    def a1(cluster, silhoutte_point)
      distance_sum = 0
      cluster.each do |point|
        distance_sum += euclidian_measure(silhoutte_point, point)
      end
      distance_sum/(cluster.length)
    end

    # Internal: Calculates the dissimilarity of a point with other clusters
    #
    # Return: Float
    #
    # Examples
    #   b1(cluster, point)
    def b1(cluster, silhoutte_point)
      cluster_avg_distance = []
      (@clusters-[cluster]).each do |cluster|
        cluster_avg_distance << a1(cluster, silhoutte_point)
      end
      cluster_avg_distance.min
    end
  end
end
