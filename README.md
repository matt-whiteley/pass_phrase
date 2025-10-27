# PassPhrase (Ruby)

<!-- Add other badges here: e.g., CI/CD, Code Coverage -->

Generates memorable passphrases based on the 'adjective-noun-verb-adjective-noun' pattern.

Example: silly-monkey-eats-fast-banana

This project is a Ruby port of the original Python Pass-phrase project by Aaron Bassett.

## Installation

Add this line to your application's Gemfile:

`gem 'pass_phrase'`


And then execute:

`$ bundle install`


Or install it yourself as:

`$ gem install pass_phrase`


You can also build and install it locally from the source:

```bash
$ gem build pass_phrase.gemspec
$ gem install ./pass_phrase-*.gem
```


## Usage

This gem can be used in two ways: as a command-line tool or as a library within another Ruby project.

### 1. As a Command-Line Tool

The pass_phrase executable allows you to generate passphrases directly from your terminal.

#### Prerequisite: Wordlists

This tool requires wordlists to function. You must provide your own text files for adjectives, nouns, and verbs (one word per line).

For example, create three files: adjectives.txt, nouns.txt, and verbs.txt.

#### Basic Usage:

```bash
$ pass_phrase --adjectives adjectives.txt --nouns nouns.txt --verbs verbs.txt

# Example Output:
# official monkey finds quick banana
```

#### Options and Customization:

You can generate multiple passphrases, change the separator, apply "leet" speak, and more.

```bash
# Generate 5 passphrases with a hyphen separator,
# with each word capitalized, and using "l33tish" text.
$ pass_phrase -n 5 -s "-" -C --l33tish \
    --adjectives adjectives.txt \
    --nouns nouns.txt \
    --verbs verbs.txt

# Example Output:
# 0ff1c14l-M0nk3y-F1nd5-Qu1ck-B4n4n4
# Gr347-D0nkey-Jumps-Sl0w-L1z4rd
# H4ppy-C47-S1ng5-L0ud-D0g
# F4s7-Turtl3-Sl33p5-5m4r7-F0x
# S1lly-R4bb17-W4lk5-B1g-P1g
```

#### Get Help:

For a full list of commands, use the help flag:

`$ pass_phrase --help`


### 2. As a Library

You can integrate PassPhrase into any Ruby project. The library raises a PassPhrase::Error if it encounters a problem (like a missing file or invalid options), which allows your application to handle failures gracefully.

#### Basic Example:

```ruby
require 'pass_phrase'

# 1. Define your wordlist paths
adj_file = 'path/to/adjectives.txt'
noun_file = 'path/to/nouns.txt'
verb_file = 'path/to/verbs.txt'

# 2. Define your options as a Hash
options = {
  num: 3,
  separator: '_',
  capitalise: true,
  make_mini_leet: false
}

begin
  # 3. Load the wordlists
  adjectives = PassPhrase::Generator.generate_wordlist(wordfile: adj_file)
  nouns = PassPhrase::Generator.generate_wordlist(wordfile: noun_file)
  verbs = PassPhrase::Generator.generate_wordlist(wordfile: verb_file)

  # 4. Generate the passphrases
  phrases = PassPhrase::Generator.passphrase(
    adjectives,
    nouns,
    verbs,
    options
  )
  
  puts "Your new passphrases:"
  puts phrases

rescue PassPhrase::Error => e
  # Handle errors without crashing your app
  puts "Error generating passphrase: #{e.message}"
end
```

#### Using Helper Methods:

You can also use the helper methods directly if needed:

```ruby
# Convert a word to leet speak
leet_word = PassPhrase::Generator.leet("super secret")
# => "5UP3R $3(R37" (output is randomized)

# Convert a word to mini-leet speak
mini_leet_word = PassPhrase::Generator.mini_leet("admin password")
# => "4dm1n p455w0rd"

# Estimate cracking time
time = PassPhrase::Generator.cracking_time(500_000_000)
# => "about 15 years"
```

## Development

After checking out the repo, run `bundle install` to install dependencies.

To build the gem locally, run:

`$ gem build pass_phrase.gemspec`


To install it onto your local machine, run:

`$ gem install ./pass_phrase-VERSION.gem`


## Contributing

Bug reports and pull requests are welcome on GitHub at https/github.com/matt-whiteley/pass_phrase.

## License

The gem is available as open source under the terms of the MIT License.
