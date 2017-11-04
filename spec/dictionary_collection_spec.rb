require "classifier"
require "dictionary_collection"
require "ostruct"
require "pry"

require_relative "fixtures"

RSpec.describe DictionaryCollection do
  it 'makes a dictionary with plural and past tense versions of the words provided' do
    my_dictionary = DictionaryCollection.new(PREMADE_DICTIONARY)
    match_word = my_dictionary.match_word("analyze")
    match_plural_word = my_dictionary.match_word("analyzes")
    match_past_tense_word = my_dictionary.match_word("analyzed")
    expect(match_word.first).to eq("american")
    expect(match_plural_word.first).to eq("american")
    expect(match_past_tense_word.first).to eq("american")

    match_british_word = my_dictionary.match_word("analyse")
    expect(match_british_word.first).to eq("british")
  end
end
