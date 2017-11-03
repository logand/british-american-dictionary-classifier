require "httparty"
require "linguistics"

class DictionaryCollection

  GIST_URL = "https://gist.github.com/mdg/aa4c9070ff3dbeaa5d4613cba05c2faf"
  DICTIONARY_LOOKUPS = {
    "british": { name: "british", path: "/raw/british-words.txt" },
    "american": { name: "american", path: "/raw/american-words.txt" }
  }

  def initialize
    @dictionaries = {}

    Linguistics.use( :en )
    DICTIONARY_LOOKUPS.values.each { |lookup_object| initialize_dictionary(lookup_object) }
  end

  def get_dictionary_list
    @dictionaries.keys
  end

  def initialize_dictionary(lookup_object)
    dictionary = @dictionaries[lookup_object[:name]]
    if dictionary.nil? || dictionary.empty?
      word_list = fetch_word_list(lookup_object[:path], lookup_object[:path])
      dictionary = generate_dictionary(word_list)
      @dictionaries[lookup_object[:name]] = dictionary
    end
  end

  def fetch_word_list(path, name)
    url = GIST_URL + path
    response = HTTParty.get(url)
    word_list = response.body.split("\n").lazy
                                         .map(&:strip)
                                         .reject(&:empty?)
                                         .force
  end

  def generate_dictionary(word_list)
    dict = {}
    word_list.each do |word|
      dict[word] = true
      dict[word.en.plural] = true
      dict[word.en.past_tense] = true
    end

    dict
  end

  # TODO: Can a word match against multiple dictionaries or is it exclusive?
  def match_word(word)
    matches = []
    @dictionaries.keys.each do |dictionary_name|
      if @dictionaries[dictionary_name][word]
        matches.push(dictionary_name)
      end
    end
    matches
  end
end
