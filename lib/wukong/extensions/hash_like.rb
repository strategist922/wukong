module Wukong
  #
  # A hashlike has to
  #
  # *
  # * The arguments to your initializer should be the same as the keys, in order
  #   If not, you must override #from_hash
  #
  #
  module HashLike

    # List of possible keys --
    # delegates to the class
    def keys
      self.class.keys
    end

    #
    # Return a Hash containing only values for the given keys.
    #
    # Since this is intended to mirror Hash#slice it will harmlessly ignore keys
    # not present in the struct.  They will be unset (hsh.include? is not true)
    # as opposed to nil.
    #
    def slice *keys
      keys.inject({}) do |hsh, key|
        hsh[key] = send(key) if respond_to?(key)
        hsh
      end
    end

    #
    # values_at like a hash
    #
    # Since this is intended to mirror Hash#values_at it will harmlessly ignore
    # keys not present in the struct
    #
    def values_of *keys
      keys.map{|key| self.send(key) if respond_to?(key) }
    end

    #
    # Convert to a hash
    #
    def to_hash
      slice(*self.class.members)
    end

    #
    # Analagous to Hash#each_pair
    #
    def each_pair *args, &block
      self.to_hash.each_pair(*args, &block)
    end

    #
    # Analagous to Hash#merge
    #
    def merge *args
      self.dup.merge! *args
    end
    def merge! hsh, &block
      raise "can't handle block arg yet" if block
      hsh.each_pair{|key, val| self.send("#{key}=", val) if self.respond_to?("#{key}=") }
      self
    end
    alias_method :update, :merge!

    module ClassMethods
      #
      # Instantiate an instance of the struct from a hash
      #
      # Specify has_symbol_keys if the supplied hash's keys are symbolic;
      # otherwise they must be uniformly strings
      #
      def from_hash(hsh, has_symbol_keys=false)
        keys = self.keys
        keys = keys.map(&:to_sym) if has_symbol_keys
        self.new *hsh.values_of(*keys)
      end
    end

    def self.included base
      p base
      base.class_eval do
        extend ClassMethods
      end
    end
  end
end