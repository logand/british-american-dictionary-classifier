# british-american-dictionary-classifier

To run the program, use the following commands:
```sh
gem install bundler
bundle install
ruby product_classifier.rb

```

This program is a solution to the problem outlined in this [Gist](https://gist.github.com/mdg/aa4c9070ff3dbeaa5d4613cba05c2faf).

The basic goal is to fetch products from the TpT GraphQL graph and classify the country of origin for each one according to the localized language used within the product name and description using the regionalized word lists provided.

To aid in the development of the dictionary matching algorithm, I developed a more verbose output to understand the matching in both libraries for the linguistics (conjugated words) vs the naive approach of substring matches.

```ruby
{:id=>"135502", :american_matches=>[{:word=>"literature", :matches=>[], :substring_matches=>["liter"]}], :british_matches=>[{:word=>"humours", :matches=>["humours"], :substring_matches=>["humour", "humours"]}], :classification=>"british"}
{:id=>"536841", :american_matches=>[], :british_matches=>[], :classification=>"unknown"}
{:id=>"723439", :american_matches=>[{:word=>"colors", :matches=>["colors"], :substring_matches=>["color", "colors"]}], :british_matches=>[], :classification=>"american"}
{:id=>"1224072", :american_matches=>[{:word=>"centers", :matches=>["centers"], :substring_matches=>["center", "centers"]}], :british_matches=>[], :classification=>"american"}
{:id=>"2723439", :american_matches=>[{:word=>"humor", :matches=>["humor"], :substring_matches=>["humor"]}, {:word=>"analysed", :matches=>["analysed"], :substring_matches=>["analyse", "analysed"]}, {:word=>"humor", :matches=>["humor"], :substring_matches=>["humor"]}, {:word=>"licensed", :matches=>["licensed"], :substring_matches=>["license", "licensed"]}], :british_matches=>[{:word=>"humour", :matches=>["humour"], :substring_matches=>["humour"]}, {:word=>"analysed", :matches=>["analysed"], :substring_matches=>["analyse", "analysed"]}, {:word=>"humour", :matches=>["humour"], :substring_matches=>["humour"]}], :classification=>"mixed"}
{:id=>"2939135", :american_matches=>[{:word=>"collaborating", :matches=>[], :substring_matches=>["labor"]}, {:word=>"collaboration", :matches=>[], :substring_matches=>["labor"]}, {:word=>"colored", :matches=>["colored"], :substring_matches=>["color", "colored"]}], :british_matches=>[], :classification=>"american"}
```
