require "graphql/client"
require "graphql/client/http"
require "linguistics"
require "httparty"
require "loofah"
require "pry"

GIST_URL = "https://gist.github.com/mdg/aa4c9070ff3dbeaa5d4613cba05c2faf"
AMERICAN_URL = GIST_URL + "/raw/american-words.txt"
BRITISH_URL = GIST_URL + "/raw/british-words.txt"

# Get American and British Word Lists
response = HTTParty.get(AMERICAN_URL)
american_words = response.body.split("\n").lazy
                                          .map(&:strip)
                                          .reject(&:empty?)
                                          .force
response = HTTParty.get(BRITISH_URL)
british_words = response.body.split("\n").lazy
                                         .map(&:strip)
                                         .reject(&:empty?)
                                         .force

# Get Products for Classification
product_numbers = File.open("data/products.txt").map { |line| line.to_i }

result_classification = []
product_classification = { british: [], american: [], mixed: [], unknown: [] }

Linguistics.use( :en )

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
  name = Loofah.fragment(product.name).text
  description = Loofah.fragment(product.description).text
  check_string(name, dialect_dictionary) || check_string(description, dialect_dictionary)
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

# Alternatives for logical checks/testing

def check_for_dictionary_words_with_matches(product, dialect_dictionary)
  name = Loofah.fragment(product.name).text
  description = Loofah.fragment(product.description).text
  matches = check_string_with_matches(name, dialect_dictionary)
  matches + check_string_with_matches(description, dialect_dictionary)
end

def check_string_with_matches(string, dialect_dictionary)
  matches = string.split(" ").reduce([]) do |match_arr, word|
    substring_matches = []
    word_matches = dialect_dictionary.select do |comparison_word|
                     substring_matches.push(comparison_word) if word.include? comparison_word
                     compare_strings(word, comparison_word)
                   end
    match_arr.push({ word: word, matches: word_matches, substring_matches: substring_matches }) if word_matches.length > 0 || substring_matches.length > 0
    match_arr
  end
end

def compare_strings(word, dictionary_word)
  comparison_word = word.gsub(/[^[:alpha:]]/i, '')

  # Match the word, pluralized form, past tense form
  case comparison_word
  when dictionary_word
    true
  when dictionary_word.en.plural
    true
  when dictionary_word.en.past_tense
    true
  else
    false
  end
end

###

def classify_product(product, has_american_words, has_british_words, classification_dictionary)
  case
  when has_british_words && has_american_words
    "mixed"
  when !has_british_words && !has_american_words
    "unknown"
  when has_british_words
    "british"
  when has_american_words
    "american"
  end
end

result.data.products.each do |product|
    american_matches = check_for_dictionary_words_with_matches(product, american_words)
    match_sum = american_matches.map { |match_obj| match_obj[:matches].length }
    has_american_words = match_sum.sum > 0
    british_matches = check_for_dictionary_words_with_matches(product, british_words)
    match_sum = british_matches.map { |match_obj| match_obj[:matches].length }
    has_british_words = match_sum.sum > 0
    classification = classify_product(product, has_american_words, has_british_words, product_classification)
    product_classification[classification.to_sym].push(product.id)
    result_classification.push({ id: product.id, american_matches: american_matches, british_matches: british_matches, classification: classification })
end

# puts result_classification
puts "The results of analyzing the words in each product lead us to classify them as follows: #{product_classification}"
