BRITISH_WORD_LIST = [
  "colour",
  "flavour",
  "humour",
  "labour",
  "centre",
  "fibre",
  "litre",
  "analyse",
]

AMERICAN_WORD_LIST = [
  "fiber",
  "liter",
  "theater",
  "analyze",
]

PREMADE_DICTIONARY = [{ name: "british", dictionary: BRITISH_WORD_LIST }, { name: "american", dictionary: AMERICAN_WORD_LIST }]

CLASSIFICATION_ITEM = {:id=>1, :strings=>["Body pumpkin spice siphon robusta", "Milk galão pumpkin spice cortado cinnamon rich. Crema, kopi-luwak, crema lungo black ristretto eu lungo."]}

TEST_PRODUCT = OpenStruct.new({
  :name => "Body pumpkin spice siphon robusta",
  :id => 1,
  :description => "Milk galão pumpkin spice cortado cinnamon rich. Crema, kopi-luwak, crema lungo black ristretto eu lungo."
})

def make_test_item(id: nil, name: nil, description: nil)
  product = OpenStruct.new({
              :name => name || TEST_PRODUCT.name,
              :id => id || TEST_PRODUCT.id,
              :description => description || TEST_PRODUCT.description
            })
  Classifier.generate_classification_item_from_product(product)
end
