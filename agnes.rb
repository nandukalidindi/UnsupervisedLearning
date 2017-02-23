# *****************************************************************
# NOTE: Please place the training and test CSV files in the same folder as the file
# NOTE: ruby agnes.rb to run the program
# *****************************************************************

require_relative './silhouette_coefficient'
@distance_matrix = []
@clusters = []

# Internal: Initialize and populate distances between each point in the dataset
#           This matrix is a must, else the program will choke trying to calculate
#           the distance measure each and everytime
#
# @distance_matrix instance variable is being populated and is used across the
# scope of this algorithm
#
# Return: nil
#
# Examples
#   populate_distance_map
#   => nil
def populate_distance_map
  @distance_matrix = @clusters.length.times.map { |x| [] }
  @clusters.each do |x|
    @clusters.each do |y|
      distance = euclidian_measure(x.first.last, y.first.last)
      @distance_matrix[x.first.first][y.first.first] = distance
      @distance_matrix[y.first.first][x.first.first] = distance
    end
  end
end

# Internal: Merge two clusters at indices index1 and index2 to form a new
#           combined cluster at index1
#
# Return: nil
#
# Examples
#   agnes
#   => nil
def agnes
  @clusters = (0..data.length-1).map { |x| [data[x]]}
  populate_distance_map
  cluster_iteration = data.length
  while cluster_iteration > 20 # Dendogram cutoff after 20 clusters are formed
    distance = Float::INFINITY
    min = Float::INFINITY
    mergable_cluster_index1 = nil
    mergable_cluster_index2 = nil
    @clusters.each_with_index do |x, i|
      @clusters.each_with_index do |y, j|
        unless i == j
          distance = single_link_distance(x, y)
          if distance < min
            min = distance
            mergable_cluster_index1 = i
            mergable_cluster_index2 = j
          end
        end
      end
    end
    @clusters = merge_clusters(mergable_cluster_index1, mergable_cluster_index2)
    cluster_iteration -= 1
  end
  @clusters
end

# Internal: Merge two clusters at indices index1 and index2 to form a new
#           combined cluster at index1
#
# Return: nil
#
# Examples
#   merge_clusters(2, 10)
#   => nil
def merge_clusters(index1, index2)
  @clusters.each_with_index do |x, index|
    if index == index2
      @clusters[index2].each do |c|
        @clusters[index1].push(c)
      end
      @clusters[index2] = nil
    end
  end
  @clusters = @clusters.select{ |x| x != nil }
end

# Internal: Distance between nearest points across two clusters c1 c2
#
# Return: Float
#
# Examples
#   single_link_distance([[1.0, 2.0, 3.0, 4.0]], [[0.0, 1.0, 2.0, 3.0]])
#   => 2
def single_link_distance(c1, c2)
  min = Float::INFINITY
  distance = 0
  c1.each do |x|
    c2.each do |y|
      distance = @distance_matrix[x.first][y.first]
      min = distance if distance < min
    end
  end
  min
end

# Internal: Manhattan distance calculator
#
# Return: Float
#
# Examples
#   manhattan_measure([1.0, 2.0, 3.0, 4.0], [0.0, 1.0, 2.0, 3.0])
#   => 4
def manhattan_measure(p1, p2)
  size = [p1.size, p2.size].max
  (0..size-1).inject(0.0) { |sum, i| sum + ( ( (p1[i] || 0) - (p2[i] || 0) ).abs) }
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

# Internal: Memoization method to prevent redundant data preprocess
#
# Return: Array
#
# Examples
#   data
def data
  # This is a common memoization technique used in Ruby
  @data ||= preprocess_data
end

# Internal: Read data from an input CSV file
#
# Return: Array
#
# Examples
#   preprocess_data("votes-train.csv")
#   => [[1, [features]], [2, [features]], [3, [features]]]
def preprocess_data
  classified_data = []
  index = 0
  File.open("iris.data", "r") do |f|
    f.each_line do |line|
      next if line.chomp.empty?
      partition = line.partition(",")
      classified_data << [index, partition.last.chomp.split(",").map(&:to_f)]
      index += 1
    end
  end
  classified_data
end

def clusterer
  @clusters = []
  agnes.each_with_index do |x, index|
    print "CLUSTER #{index}: "
    p x.length
    @clusters[index] = x.map { |k| k.last }
  end

  @clusters.each_with_index do |x, index|
    print "CLUSTER #{index+1}: "
    print "#{x.length}(size) "
    p "Silhouette Coefficient: #{SilhouetteCoefficient.silhouette_coefficient(x, @clusters)}"
  end
end

#OUTPUT

# CLUSTER 0: 2308   Silhouette: 0.637483458953335
# CLUSTER 1: 1      Silhouette: 1.0
# CLUSTER 2: 1      Silhouette: 1.0
# CLUSTER 3: 1      Silhouette: 1.0
# CLUSTER 4: 1      Silhouette: 1.0
# CLUSTER 5: 4      Silhouette: 0.7843654469225305
# CLUSTER 6: 1      Silhouette: 1.0
# CLUSTER 7: 3      Silhouette: 0.7454163850685841
# CLUSTER 8: 1      Silhouette: 1.0
# CLUSTER 9: 1      Silhouette: 1.0
# CLUSTER 10: 1     Silhouette: 1.0
# CLUSTER 11: 1     Silhouette: 1.0
# CLUSTER 12: 1     Silhouette: 1.0
# CLUSTER 13: 1     Silhouette: 1.0
# CLUSTER 14: 2     Silhouette: 0.944062951161708
# CLUSTER 15: 2     Silhouette: 0.8494818155755182
# CLUSTER 16: 1     Silhouette: 1.0
# CLUSTER 17: 1     Silhouette: 1.0
# CLUSTER 18: 1     Silhouette: 1.0
# CLUSTER 19: 1     Silhouette: 1.0
