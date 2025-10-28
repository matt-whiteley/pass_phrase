# PassPhrase (Ruby)

Generates memorable passphrases based on the 'adjective-noun-verb-adjective-noun' pattern, such as `silly-monkey-eats-fast-banana`.

This gem comes bundled with default wordlists for adjectives, nouns, and verbs, making it easy to get started with zero configuration.

This project is a Ruby port of the original Python [Pass-phrase](https://github.com/aaronbassett/Pass-phrase) project by Aaron Bassett.

## Installation
Add this line to your application's `Gemfile`:

```ruby
gem 'pass_phrase'
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install pass_phrase
```

## Library Usage
This gem is designed to be used as a library within your Ruby projects.

The main entry point is the `PassPhrase::Generator.passphrase(options = {})` method. It accepts a single hash of options and returns a string of one or more passphrases.

The library raises a `PassPhrase::Error` if it encounters a problem (e.g., a custom wordlist file is not found), allowing your application to handle failures gracefully.

### Basic Example (Using Default Wordlists)
By default, the gem will use its own bundled wordlists. You only need to provide options for formatting.

```ruby
require 'pass_phrase'

# 1. Define your options as a Hash
#    (No file paths are needed)
options = {
  num: 3,
  separator: '_',
  capitalise: true
}

begin
  # 2. Generate the passphrases
  phrases = PassPhrase::Generator.passphrase(options)
  
  puts "Your new passphrases:"
  puts phrases

rescue PassPhrase::Error => e
  # Handle errors without crashing your app
  puts "Error generating passphrase: #{e.message}"
end
```

### Advanced Example (Overriding Wordlists & Options)
To use your own custom wordlists, simply pass their file paths in the options hash. You can also mix in other options like l33t speak or word length constraints.

```ruby
require 'pass_phrase'

options = {
  num: 2,
  separator: ' ',
  
  # --- Custom Wordlists ---
  adjectives: 'path/to/my_adjectives.txt',
  nouns: 'path/to/my_nouns.txt',
  verbs: 'path/to/my_verbs.txt',
  
  # --- Other Options ---
  min_length: 4,      # Only use words 4 characters or longer
  make_leet: true     # Apply full 'l33t' speak
}

begin
  phrases = PassPhrase::Generator.passphrase(options)
  puts phrases

rescue PassPhrase::Error => e
  puts "Error: #{e.message}"
end
```

### Using Helper Methods
The generator's helper methods are also public and can be used individually if needed.

```ruby
# Convert a word to leet speak
leet_word = PassPhrase::Generator.leet("super secret")
# => "5UP3R $3(R37" (output is randomized)

# Convert a word to mini-leet speak
mini_leet_word = PassPhrase::Generator.mini_leet("admin password")
# => "4dm1n p455w0rd"

# Estimate cracking time (at 1,000 guesses/sec)
time = PassPhrase::Generator.cracking_time(500_000_000)
# => "about 15 years"
```

## Development
After checking out the repo, run `bundle install` to install dependencies.

To build the gem locally, run:

```bash
$ gem build pass_phrase.gemspec
```

To install it onto your local machine, run:

```bash
$ gem install ./pass_phrase-VERSION.gem
```

## Contributing
Bug reports and pull requests are welcome on GitHub at https://github.com/matt-whiteley/pass_phrase.

## License
The gem is available as open source under the terms of the [MIT License](https://github.com/matt-whiteley/pass_phrase/LICENSE.txt).