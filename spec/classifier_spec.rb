require "classifier"
require "dictionary_collection"
require "ostruct"

require_relative "fixtures"

RSpec.describe Classifier do
  my_dictionary = DictionaryCollection.new(PREMADE_DICTIONARY)
  my_classifier = Classifier.new(my_dictionary)

  it 'sanitizes html from text strings' do
    cleaned_string = Classifier.scrub_html("<strong itemprop='name'>Hello World!</strong>")
    expect(cleaned_string).to eq('Hello World!')
  end

  it 'strips non-character chars from string' do
    cleaned_string = Classifier.strip_word_for_comparison("Héllo!")
    expect(cleaned_string).to eq("héllo")
  end

  it 'generates a classification object from a product' do
    classification_item = Classifier.generate_classification_item_from_product(TEST_PRODUCT)
    expect(classification_item).to eq(CLASSIFICATION_ITEM)
  end

  context 'it classifies items' do
    it 'generates a british classification for humours' do
      classification_item = make_test_item(id: 2, name: "humours of the mind")
      my_classifier.process_item(classification_item)
      expect(my_classifier.id_in_classification(classification_item[:id], "british")).to eq(true)
    end

    context 'it classifies theater' do
      classification_item = make_test_item(id: 3, name: "I love going to the theater")
      my_classifier.process_item(classification_item)

      it 'generates an american classification for theater' do
        expect(my_classifier.id_in_classification(classification_item[:id], "american")).to eq(true)
      end

      it 'does not generate a british classification for theater' do
        expect(my_classifier.id_in_classification(classification_item[:id], "british")).to eq(false)
      end
    end

    it 'generates an unknown classification for literature even though liter is a substring' do
      classification_item = make_test_item(id: 4, name: "I try to read a wide range of literature")
      my_classifier.process_item(classification_item)
      expect(my_classifier.id_in_classification(classification_item[:id], "unknown")).to eq(true)
    end

    it 'generates a mixed classification for liter and flavour' do
      classification_item = make_test_item(id: 5, name: "I mix lots of flavoured liters of soda")
      my_classifier.process_item(classification_item)
      expect(my_classifier.id_in_classification(classification_item[:id], "mixed")).to eq(true)
    end
  end
end
