require "graphql/client"
require "graphql/client/http"
require "pry"

product_numbers = File.open("data/products.txt").map { |line| line.to_i }
american_words = File.open("data/american-words.txt").map { |line| line }
british_words = File.open("data/british-words.txt").map { |line| line }

HTTP = GraphQL::Client::HTTP.new("https://www.teacherspayteachers.com/graph/graphql")

if (File.exist?("data/schema.json"))
  Schema = GraphQL::Client.load_schema("data/schema.json")
else
  Schema = GraphQL::Client.load_schema(HTTP)
  GraphQL::Client.dump_schema(HTTP, "data/schema.json")
end

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

puts result.data.products.length
