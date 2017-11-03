require "graphql/client"
require "graphql/client/http"
require "pry"

require_relative "lib/dictionary_collection"
require_relative "lib/classifier"
require_relative "lib/tpt_graph"

product_ids = File.open("data/products.txt").map { |line| line.to_i }
products = TPT_GRAPH.fetch_products(product_ids)

classification_dictionary = DictionaryCollection.new
product_classifier = Classifier.new(classification_dictionary)

products.each do |product|
  classification_item = Classifier.generate_classification_item_from_product(product)
  product_classifier.process_item(classification_item)
end

puts product_classifier
