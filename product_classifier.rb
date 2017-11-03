require "graphql/client"
require "graphql/client/http"
require "pry"

require_relative "lib/dictionary_collection"
require_relative "lib/classifier"

# Get Products for Classification
product_numbers = File.open("data/products.txt").map { |line| line.to_i }

HTTP = GraphQL::Client::HTTP.new("https://www.teacherspayteachers.com/graph/graphql")

Client = GraphQL::Client.new(schema: Schema, execute: HTTP)

ProductLookupQuery = Client.parse <<-'GRAPHQL'
query($productIds: [ID]!) {
    products(ids: $productIds) {
        id
        name
        description
    }
}
GRAPHQL

result = Client.query(ProductLookupQuery, variables: { "productIds": product_numbers })

classification_dictionary = DictionaryCollection.new
product_classifier = Classifier.new(classification_dictionary)

result.data.products.each do |product|
  classification_item = Classifier.generate_classification_item_from_product(product)
  product_classifier.process_item(classification_item)
end

puts product_classifier
