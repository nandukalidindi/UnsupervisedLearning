# *****************************************************************
# NOTE: Please place the training and test CSV files in the same folder as the file
# NOTE: ruby kmeans.rb to run the program
# *****************************************************************

require_relative './silhouette_coefficient'

@feature_count = 9

# Internal: Algorithm to cluster data using K MEANS into K clusters
#
# Return: Array (clusters)
#
# Examples
#   cluster_mean([[1.0, 2.0, 3.0, 4.0], [0.0, 1.0, 2.0, 3.0]])
#   => [0.5, 1.5, 2.5, 3.5]
def k_means(k)
  centroids = random_centroids(k, data)
  breakable = false
  old_cluster_length_map = k.times.map { |x| 0 }
  while !breakable
    clusters = k.times.map { |x| [] }
    data.each do |x|
      min_distance = Float::INFINITY
      cluster = 0
      (0..k-1).each do |c|
        euclidian = euclidian_measure(x, centroids[c])
        if euclidian < min_distance
          cluster = c
          min_distance = euclidian
        end
      end
      clusters[cluster] << x
    end
    new_cluster_length_map = clusters.map { |x| x.length }
    breakable = !(0..k-1).map { |x| old_cluster_length_map[x] == new_cluster_length_map[x] }.include?(false)
    if breakable
      break
    else
      old_cluster_length_map = new_cluster_length_map
      centroids = clusters.map { |x| cluster_mean(x) }
    end
  end
  clusters
end

# Internal: Calculates the centroid of a cluster by mean of each feature
#
# Return: Array
#
# Examples
#   cluster_mean([[1.0, 2.0, 3.0, 4.0], [0.0, 1.0, 2.0, 3.0]])
#   => [0.5, 1.5, 2.5, 3.5]
def cluster_mean(cluster)
  mean = []
  (0..@feature_count-1).each_with_index do |x, index|
    feature_index_map = cluster.map { |k| k[index] }
    feature_index_mean = feature_index_map.inject(0) { |sum, value| sum+value }/(feature_index_map.length.to_f)
    mean[index] = feature_index_mean
  end
  mean
end

# Internal: Euclidian distance calculator
#
# Return: Float
#
# Examples
#   euclidian_measure([1.0, 2.0, 3.0, 4.0], [0.0, 1.0, 2.0, 3.0])
#   => 2
def euclidian_measure(p1, p2)
  size = [p1.size, p2.size].max
  sum = (0..size-1).inject(0.0) { |sum, i| sum + ( ( (p1[i] || 0) - (p2[i] || 0) ) ** 2 ) }
  sum ** 0.5
end

# Internal: Initial centroids that are selected at random based on the range of
#           each feature to start K MEANS algorithm
#
# Return: Array
#
# Examples
#   random_centroids(3, data)
#   => [[centroid1], [centroid2], [centroid3]]
def random_centroids(k, data)
  centroids = []
  min_max_mapper = []
  feature_index_map = []
  (0..@feature_count-1).each_with_index do |x, index|
    feature_index_map = data.map { |k| k[index] }
    min_max_mapper << [feature_index_map.min, feature_index_map.max]
  end
  (0..k-1).each do |x|
    centroids << (0..@feature_count-1).map { |x| rand(min_max_mapper[x].first..min_max_mapper[x].last) }
  end
  centroids
end

# Internal: Memoization method to prevent redundant data preprocess
#
# Return: Array
#
# Examples
#   data
def data
  # This is a common memoization technique used in Ruby
  @data ||= normalize_data
end

# Internal: Read data from an input CSV file
#
# Return: Array
#
# Examples
#   preprocess_data("votes-train.csv")
#   => [[[features], 1], [[features], 2], [[features], 3]]
def preprocess_data(file_name = "votes-train.csv")
  consolidated_array = []
  File.open(file_name, "r") do |f|
    f.each_line do |line|
      next if line.chomp.empty?
      partition = line.partition(',')
      point = partition.last.chomp.split(',').map(&:to_f)
      consolidated_array << point
    end
  end
  consolidated_array
end

# Internal: Normalize data to get all values to [0, 1] range. Feature Scaling!
#
# Return: Array
#
# Examples
#   normalize_data("votes-train.csv")
#   => [[features], [features], [features]] Scaled data
def normalize_data(file_name = "votes-train.csv")
  data = preprocess_data(file_name)
  ranges = []
  sum = 0
  @feature_count = data.first.length
  (0..@feature_count-1).each do |i|
    feature_array = data.map { |x| x[i] }
    sum = feature_array.inject(0) { |sum, i| sum+i }/(feature_array.length)
    ranges[i] = [sum, feature_array.max - feature_array.min]
  end
  data.each_with_index do |x, index|
    data[index] = (0..@feature_count-1).map { |k| (x[k]-ranges[k][0])/(ranges[k][1]) }
  end
  data
end

def clusterer
  @clusters = k_means(2)

  @clusters.each_with_index do |x, index|
    print "CLUSTER #{index+1}: "
    print "#{x.length}(size) "
    p "Silhouette Coefficient: #{SilhouetteCoefficient.silhouette_coefficient(x, @clusters)}"
  end
end

clusterer

# 0.3719061498378222
# 0.3814364697742049
