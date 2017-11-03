require "graphql/client"
require "graphql/client/http"

module TPT_GRAPH
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

  def self.fetch_products(product_ids)
    result = Client.query(ProductLookupQuery, variables: { "productIds": product_ids })
    result.data.products if result.data
  end
end
