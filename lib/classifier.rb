require "loofah"

class Classifier
  def initialize(dictionary)
    @dictionary = dictionary
    @classifications = { "mixed": [], "unknown": []}

    build_classifications_hash
  end

  def build_classifications_hash
    @dictionary.get_dictionary_list.each do |dictionary_type|
      @classifications[dictionary_type.to_sym] ||= []
    end
  end

  def self.generate_classification_item_from_product(product)
    { id: product.id, strings: [Classifier.scrub_html(product.name), Classifier.scrub_html(product.description)] }
  end

  def self.scrub_html(string)
    Loofah.fragment(string).text
  end

  def self.strip_word_for_comparison(word)
    word.gsub(/[^[:alpha:]]/i, '').downcase
  end

  def process_item(classification_item)
    item_classifications = []

    classification_item[:strings].each do |string|
      classifications = string.split(" ").reduce([]) do |match_arr, word|
                                break match_arr if match_arr.length > 1
                                match_arr += check_word(word)
                                match_arr.uniq
                              end
      item_classifications = (item_classifications + classifications).uniq
      break if item_classifications.length > 1
    end
    classify_item(classification_item[:id], item_classifications)
  end

  def check_word(word)
    matches = []
    word = Classifier.strip_word_for_comparison(word)
    if word.length > 0
      matches = @dictionary.match_word(word)
    end

    matches
  end

  def classify_item(id, item_classifications)
    case item_classifications.length
    when 0
      @classifications[:unknown].push(id)
    when 1
      @classifications[item_classifications.first.to_sym].push(id)
    when 2
      @classifications[:mixed].push(id)
    end
  end

  def to_s
    "The results of analyzing the words in each product lead us to classify them as follows: #{@classifications}"
  end

end
