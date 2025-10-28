# frozen_string_literal: true

require_relative "pass_phrase/version"
require 'set'

module PassPhrase
  class Error < StandardError; end

  # This finds the root directory of the gem and builds a path
  def self.gem_datapath(filename)
    # File.expand_path takes a path relative to the __dir__ (current file's dir)
    # __dir__ is /.../pass_phrase-0.1.0/lib/pass_phrase
    # ../../ gives /.../pass_phrase-0.1.0/
    # Then we append 'data/pass_phrase' and the filename
    File.expand_path(File.join(__dir__, '..', '..', 'data', 'pass_phrase', filename))
  end

  # A map of 'geek' letters for leet-speak
  LEET_LETTERS = {
    "a" => ["4", "@"], "b" => ["8"], "c" => ["("], "e" => ["3"],
    "f" => ["ph", "pH"], "g" => ["9", "6"], "h" => ["#"],
    "i" => ["1", "!", "|"], "l" => ["!", "|"], "o" => ["0", "()"],
    "q" => ["kw"], "s" => ["5", "$"], "t" => ["7"], "x" => ["><"],
    "y" => ["j"], "z" => ["2"]
  }.freeze

  MINI_LEET_LETTERS = {
    "a" => "4", "b" => "8", "e" => "3", "g" => "6",
    "i" => "1", "o" => "0", "s" => "5", "t" => "7", "z" => "2"
  }.freeze

  class Generator
    # This is the entry point.
    # It accepts an options hash, validates it, loads the
    # necessary files, and returns the generated passphrases.
    def self.passphrase(options = {})
      # 1. Validate options and populate defaults (mutates options hash)
      validate_options(options)

      # 2. Load wordlists based on options
      adj_opts = options.merge(wordfile: options[:adjectives])
      noun_opts = options.merge(wordfile: options[:nouns])
      verb_opts = options.merge(wordfile: options[:verbs])
      
      adjectives = generate_wordlist(adj_opts)
      nouns = generate_wordlist(noun_opts)
      verbs = generate_wordlist(verb_opts)

      # 3. Run verbose report if requested
      if options[:verbose]
        verbose_reports(adjectives: adjectives, nouns: nouns, verbs: verbs, options: options)
      end

      # 4. Generate the phrases
      separator = options.fetch(:separator, ' ')
      num = options.fetch(:num, 1)
      uppercase = options.fetch(:uppercase, false)
      lowercase = options.fetch(:lowercase, false)
      capitalise = options.fetch(:capitalise, false)
      random = options.fetch(:random, Random.new)

      phrases = []
      num.times do
        phrase = generate_passphrase_internal(adjectives, nouns, verbs, separator: separator, random: random)
        
        if capitalise
          phrase = phrase.split(separator).map(&:capitalize).join(separator)
        end
        phrases << phrase
      end
      
      all_phrases = phrases.join("\n")

      if uppercase
        all_phrases.upcase!
      elsif lowercase
        all_phrases.downcase!
      end
      
      all_phrases
    end

    # Generate a word list from a file
    def self.generate_wordlist(options = {})
      wordfile = options.fetch(:wordfile) # This is guaranteed by validate_options
      min_length = options.fetch(:min_length, 0)
      max_length = options.fetch(:max_length, 20)
      valid_chars = options.fetch(:valid_chars, '.')
      make_leet = options.fetch(:make_leet, false)
      make_mini_leet = options.fetch(:make_mini_leet, false)

      words = []
      regexp = Regexp.new("^[#{valid_chars}]{#{min_length},#{max_length}}$")
      
      begin
        filepath = File.expand_path(wordfile)
        File.foreach(filepath) do |line|
          thisword = line.strip
          if regexp.match?(thisword)
            if make_mini_leet
              thisword = mini_leet(thisword)
            elsif make_leet
              thisword = leet(thisword)
            end
            words << thisword
          end
        end
      rescue Errno::ENOENT
        raise PassPhrase::Error, "Error: Could not find word file at #{filepath}"
      end

      if words.length < 1
        raise PassPhrase::Error, "Error: Could not get enough words! " \
                                 "This could be a result of either #{wordfile} being too small, " \
                                 "or your settings too strict."
      end
      words
    end

    # Generate a single adjective-noun-verb-adjective-noun phrase
    def self.generate_passphrase_internal(adjectives, nouns, verbs, separator:, random:)
      [
        adjectives.sample(1, random: random).first,
        nouns.sample(1, random: random).first,
        verbs.sample(1, random: random).first,
        adjectives.sample(1, random: random).first,
        nouns.sample(1, random: random).first
      ].join(separator)
    end

    # --- Leet Speak Helpers ---

    def self.leet(word)
      geek_word = ""
      word.each_char do |letter|
        l = letter.downcase
        if LEET_LETTERS.key?(l)
          # swap out the letter *most* (80%) of the time
          if rand(1..5) % 5 != 0
            geek_word += LEET_LETTERS[l].sample
          else
            # uppercase it *some* (10%) of the time
            geek_word += (rand(1..10) % 10 != 0) ? letter.upcase : letter
          end
        else
          geek_word += letter
        end
      end
      
      # if last letter is an S, swap it out half the time
      if word.end_with?('s', 'S') && rand(1..2) % 2 == 0
        geek_word = geek_word[0...-1] + "zz"
      end
      geek_word
    end

    def self.mini_leet(word)
      word.chars.map do |letter|
        MINI_LEET_LETTERS.fetch(letter.downcase, letter)
      end.join
    end

    # --- Validation and Reporting ---

    def self.validate_options(options)
      if options.fetch(:num, 1) <= 0
        raise PassPhrase::Error, "Little point running the script if you " \
                                 "don't generate even a single passphrase."
      end

      if options.fetch(:max_length, 20) < options.fetch(:min_length, 0)
        raise PassPhrase::Error, "The maximum length of a word can not be " \
                                 "lesser then minimum length."
      end

      # Check for word files
      [:adjectives, :nouns, :verbs].each do |word_type|
        # 1. If the user did NOT provide a file path, use the gem's default
        if options[word_type].nil?
          default_path = PassPhrase.gem_datapath("#{word_type}.txt")
          options[word_type] = default_path
        else
        # 2. If the user DID provide a path, expand it
          options[word_type] = File.expand_path(options[word_type])
        end

        # 3. Now, check if the chosen file (default or custom) actually exists
        unless File.exist?(options[word_type])
          raise PassPhrase::Error, "Error: Could not find #{word_type} word file at: #{options[word_type]}"
        end
      end
    end

    def self.verbose_reports(adjectives:, nouns:, verbs:, options:)
      f = {}
      [:adjectives, :nouns, :verbs].each do |word_type|
        puts "The supplied #{word_type} list is located at #{File.expand_path(options[word_type])}."
        words = binding.local_variable_get(word_type) # Get the wordlist array
        f[word_type] = {}
        f[word_type][:length] = words.length
        f[word_type][:bits] = Math.log(f[word_type][:length], 2)

        if f[word_type][:bits] % 1 == 0
          puts "Your #{word_type} word list contains #{f[word_type][:length]} words, or 2^#{f[word_type][:bits].to_i} words."
        else
          puts "Your #{word_type} word list contains #{f[word_type][:length]} words, or 2^#{'%.2f' % f[word_type][:bits]} words."
        end
      end

      entropy = f[:adjectives][:bits] + f[:nouns][:bits] + f[:verbs][:bits] + f[:adjectives][:bits] + f[:nouns][:bits]
      
      puts "A passphrase from this list will have roughly " \
           "#{entropy.to_i} (#{f[:adjectives][:bits].round(2)} + #{f[:nouns][:bits].round(2)} + #{f[:verbs][:bits].round(2)} + #{f[:adjectives][:bits].round(2)} + #{f[:nouns][:bits].round(2)}) bits of entropy."

      combinations = (2**entropy.to_i) / 1000.0
      time_taken = cracking_time(combinations)
      puts "Estimated time to crack this passphrase (at 1,000 guesses per second): #{time_taken}\n\n"
    end

    def self.cracking_time(seconds)
      minute = 60
      hour = minute * 60
      day = hour * 24
      week = day * 7
      month = day * 30 # Approximation
      year = day * 365

      if seconds < minute
        "less than a minute"
      elsif seconds < minute * 5
        "less than 5 minutes"
      elsif seconds < minute * 10
        "less than 10 minutes"
      elsif seconds < hour
        "less than an hour"
      elsif seconds < day
        "about #{(seconds / hour).to_i} hours"
      elsif seconds < day * 14
        "about #{(seconds / day).to_i} days"
      elsif seconds < month * 2
        "about #{(seconds / week).to_i} weeks"
      elsif seconds < year * 2
        "about #{(seconds / month).to_i} months"
      else
        "about #{(seconds / year).to_i} years"
      end
    end
  end
end
