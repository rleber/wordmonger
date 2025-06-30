module WordMonger
  class Scanner
    @@scanners = {}

    class ScannerFailure < WordMonger::Error; end

    class << self
      def scanners
        @@scanners
      end

      def add_scanner(name, scanner)
        @@scanners[name] = scanner
      end

      def default
        @@default ||= self.new(nil, /\w+/)
        @@default
      end
    end

    attr_reader :name, :definition
    attr_accessor :dictionary
    def initialize(name, definition, dictionary: nil)
      @name = name
      @definition = definition
      @dictionary ||= WordMonger.active_dictionary
      self.class.add_scanner(name, self)
    end

    # TODO For future development: Compound words

    def scan(string)
      words = case @definition
      when Regexp
        string.scan(@definition)
      when Proc
        Proc.call(string)
      when nil
        single_scan(string, self.class.default)
      else
        raise ScannerFailure, "Unknow scanner type: #{scanner.inspect}"
      end
      words.map { |word| WordMonger::Word.new(word, dictionary: self.dictionary, generated: true) }
    end
  end
end