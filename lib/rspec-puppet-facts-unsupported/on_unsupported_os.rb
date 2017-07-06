require 'rspec-puppet-facts'

# A main module of rspec-puppet-facts-unsupported
module RspecPuppetFactsUnsupported
  # Fetches an unsupported list of operating system's facts. List doesn't contains operating system
  # described in Puppet's metadata.json file.
  # @return Hash[String => Hash] A hash of key being os description and value being example
  # machine facts
  # @param Hash[Symbol => Object] opts A configuration hash with options
  # @option opts [String,Array<String>] :hardwaremodels The OS architecture names, i.e. 'x86_64', /IBM/
  # or 'i86pc'
  # @option opts [Array<Hash>] :supported_os If this options is provided the data
  # will be used instead of the "operatingsystem_support" section if the metadata file
  # even if the file is missing.
  # @option opts [Array<Hash>] :filters An array of extra filters to be passed to FacterDB to
  # narrow the search
  # @option opts [Array<Hash>] :order An order in which records should be returned. You can pass values
  # like :random - to randomly shuffle records (exact shuffle seed will be printed on stderr to be able
  # to reproduce invalid behaivior), `:original` - to return original list, an integer seed - to reproduce
  # failiures. By default it is set to `:random`
  # @option opts [Array<Hash>] :limit A limit of records to be returned. By default it is set to 2.
  def on_unsupported_os(opts = {})
    process_opts(opts)
    filters = calculate_filters(opts)
    facts = FacterDB.get_facts(filters)
    op = UnsupportedFilteringOperation.new(facts, opts)
    op.facts
  end

  def self.verbose=(verbose)
    @@verbose = (verbose == true) # rubocop:disable Style/ClassVars
  end

  def self.verbose?
    @@verbose
  end

  def verbose?
    RspecPuppetFactsUnsupported.verbose?
  end

  protected

  def factname(fact, opts = {})
    opts[:era] ||= :legancy
    fact_sym = fact.to_s.to_sym
    if opts[:era] == :legancy
      fact_sym
    elsif opts[:era] == :current
      CURRENT_FACT_NAMES[fact_sym]
    else
      raise "invalid era: #{opts[:era].inspect}"
    end
  end

  private

  CURRENT_FACT_NAMES = {
    hardwaremodel: :'os.hardware',
    operatingsystem: :'os.name',
    operatingsystemrelease: :'os.release.full',
    operatingsystemmajrelease: :'os.release.major'
  }.freeze

  @@verbose = true # rubocop:disable Style/ClassVars

  # Private class to perform randomization
  class Randomizer
    attr_reader :order, :seed

    def initialize(opts, envkey = :RSPEC_PUPPET_FACTS_UNSUPPORTED_ORDER)
      opts[:order] ||= :random
      randomize_seed
      envvar = ENV[envkey.to_s]
      ordervalue = envvar.nil? ? opts[:order] : envvar.to_sym
      ilike = Integerlike.new(ordervalue)
      self.seed = ilike.to_i if ilike.integer?
      @order = ordervalue
      @repetitive_random = Random.new(42)
    end

    def get
      should_randomize? ? @randomizer : @repetitive_random
    end

    def should_randomize?
      @order == :random || Integerlike.new(@order).integer?
    end

    private

    SHORT_MAX = 2**16

    def randomize_seed
      @seed = Random.new.rand(0..SHORT_MAX)
    end

    def seed=(seed)
      @seed = seed
      @randomizer = Random.new(@seed)
    end
  end

  def process_opts(opts)
    opts[:randomizer] = Randomizer.new(opts)
    ensure_default_hardwaremodels opts
    ensure_default_filters opts
    opts[:limit] ||= 2
    opts[:supported_os] ||= RspecPuppetFacts.meta_supported_os
    process_order opts
  end

  def ensure_default_hardwaremodels(opts)
    opts[:hardwaremodels] ||= ['x86_64']
    opts[:hardwaremodels] = [opts[:hardwaremodels]] unless opts[:hardwaremodels].is_a? Array
  end

  def ensure_default_filters(opts)
    opts[:filters] ||= []
    opts[:filters] = [opts[:filters]] unless opts[:filters].is_a? Array
  end

  def process_order(opts)
    rnd = opts[:randomizer]
    message = "Shuffling unsupported OS's facts with seed: #{rnd.seed}\nSet environment variable " \
      "to reproduce this order, for ex. on Linux \`export RSPEC_PUPPET_FACTS_UNSUPPORTED_ORDER=#{rnd.seed}\`"
    $stderr.puts message if verbose? && rnd.should_randomize?
  end

  def calculate_filters(opts)
    filters = []
    opts[:hardwaremodels].each do |hardwaremodel|
      filters << {
        facterversion: "/^#{Regexp.quote(system_facter_version)}/",
        hardwaremodel: hardwaremodel
      }
    end
    filters = filters.product(opts[:filters]).collect { |x, y| x.merge(y) } unless opts[:filters].empty?
    postprocess_filters(filters)
  end

  def system_facter_version
    Facter.version.split('.')[0..-2].join('.')
  end

  def find_facter_version_matching_regexp(regexp)
    (1..4).each do |major|
      (0..7).each do |minor|
        candidate = "#{major}.#{minor}.42"
        stripped_regexp = regexp.gsub(%r{^/+|/+$}, '')
        return candidate if Regexp.new(stripped_regexp).match(candidate)
      end
    end
    nil
  end

  def postprocess_filters(filters)
    filters.map do |filter|
      facterversion = find_facter_version_matching_regexp(filter[:facterversion])
      if facterversion.split('.').first >= '3'
        current = factname(:hardwaremodel, era: :current)
        legancy = factname(:hardwaremodel)
        filter[current] = filter[legancy]
        filter.delete(legancy)
      end
      filter
    end
  end

  # Integerlike private class
  class Integerlike
    def initialize(obj)
      @obj = obj
    end

    def integer?
      to_s == to_i.to_s
    end

    def to_i
      to_s.to_i
    end

    def to_s
      @obj.to_s
    end
  end

  # Private class
  class Facts
    include RspecPuppetFactsUnsupported
    def initialize(facts)
      @facts = facts
    end
    attr_reader :facts

    def [](key)
      normalized_key = factkey(key)
      facts_by_path(facts, normalized_key)
    end

    private

    def factkey(fact)
      era = facter_current? ? :current : :legancy
      factname(fact, era: era)
    end

    def facts_by_path(facts, path)
      stringified = Hash[facts.map { |k, v| [k.to_s, v] }]
      path.to_s.split('.').inject(stringified) { |hash, key| hash[key] }
    end

    def facter_current?
      facterversion >= '3.0.0'
    end

    def facterversion
      facts[:facterversion]
    end
  end

  # Private opertion wrapper class
  class UnsupportedFilteringOperation
    include RspecPuppetFactsUnsupported
    def initialize(facts_list, opts)
      @opts = opts
      @facts_list = facts_list
    end

    def facts
      postprocess_facts(reject_supported_os)
    end

    private

    def reject_supported_os
      metadata_supported = @opts[:supported_os]
      @facts_list.reject do |candidate_raw|
        candidate = Facts.new(candidate_raw)
        req = metadata_supported.select do |single_req|
          single_req['operatingsystem'] == candidate[:operatingsystem]
        end
        should_be_rejected?(req, candidate)
      end
    end

    def postprocess_facts(facts_list)
      os_facts_hash = {}
      facts_list.map do |facts|
        description = describe_os(Facts.new(facts))
        facts.merge! RspecPuppetFacts.common_facts
        os_facts_hash[description] = RspecPuppetFacts.with_custom_facts(description, facts)
      end
      shuffle_and_limit(os_facts_hash)
    end

    def shuffle_and_limit(os_facts_hash)
      randomizer = @opts[:randomizer]
      as_array = os_facts_hash.to_a
      as_array = as_array.sort_by { |os, _| os }
      as_array = as_array.shuffle(random: randomizer.get)
      as_array = as_array[0..@opts[:limit]]
      Hash[*as_array.flatten]
    end

    def describe_os(facts)
      "#{facts[:operatingsystem].downcase}-" \
        "#{facts[:operatingsystemmajrelease]}-" \
        "#{facts[:hardwaremodel]}"
    end

    def should_be_rejected?(req, candidate)
      if req.empty?
        false
      else
        req = req.first
        operatingsystemrelease_matches?(req['operatingsystemrelease'], candidate)
      end
    end

    def operatingsystemrelease_matches?(operatingsystemrelease, candidate)
      if operatingsystemrelease.nil?
        true
      else
        candidate_release = candidate[:operatingsystemrelease]
        operatingsystemrelease.select { |elem| candidate_release.start_with?(elem) }.any?
      end
    end
  end
end
