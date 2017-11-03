require "graphql/client"
require "graphql/client/http"
require "httparty"
require "pry"

GIST_URL = "https://gist.github.com/mdg/aa4c9070ff3dbeaa5d4613cba05c2faf"
AMERICAN_URL = GIST_URL + "/raw/american-words.txt"
BRITISH_URL = GIST_URL + "/raw/british-words.txt"

# Get American and British Word Lists
response = HTTParty.get(AMERICAN_URL)
american_words = response.body.split("\n").map(&:strip).reject(&:empty?)
response = HTTParty.get(BRITISH_URL)
british_words = response.body.split("\n").map(&:strip).reject(&:empty?)

# Get Products for Classification
product_numbers = File.open("data/products.txt").map { |line| line.to_i }

result_classification = []
product_classification = { british: [], american: [], mixed: [], unknown: [] }

# american_words_map = american_words.map { |word| [word, true] }.to_h
# british_words_map = british_words.map { |word| [word, true] }.to_h

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

def check_for_dictionary_words(product, dialect_dictionary)
  found_match = false
  found_match = check_string(product.name, dialect_dictionary)

  found_match = check_string(product.description, dialect_dictionary)
end

def check_string(string, dialect_dictionary)
  found_match = false
  string.split(" ").each do |word|
    dialect_dictionary.each do |comparison_word|
      if word.include? comparison_word
        found_match = true
        break
      end
    end
  end
  found_match
end

result.data.products.each do |product|
    has_american_words = check_for_dictionary_words(product, american_words)
    has_british_words = check_for_dictionary_words(product, british_words)
    result_classification.push({ id: product.id, british_words: has_british_words, american_words: has_american_words, mixed: (has_british_words && has_american_words), unknown: (!has_british_words && !has_american_words) })
    case
    when has_british_words && has_american_words
      product_classification[:mixed].push(product.id)
    when !has_british_words && !has_american_words
      product_classification[:unknown].push(product.id)
    when has_british_words
      product_classification[:british].push(product.id)
    when has_american_words
      product_classification[:american].push(product.id)
    end
end

# puts result_classification
puts "The results of analyzing the words in each product lead us to classify them as follows: #{product_classification}"
