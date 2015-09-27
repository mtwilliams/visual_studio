module VisualStudio
  class Install
    attr_reader :name,
                :version,
                :root,
                :products

    def initialize(desc={})
      @name      = desc[:name]
      @version   = desc[:version]
      @root      = desc[:root]
      @products  = desc[:products]
    end

    def self.available?(name_or_version)
      !!(self.find(name_or_version))
    end

    def self.latest
      VisualStudio::VERSIONS.map{|version| self.find_by_version(version)}.compact.first
    end

    def self.find(name_or_version)
      if VisualStudio::NAMES.include?(name_or_version)
        self.find_by_name(name_or_version)
      elsif VisualStudio::VERSIONS.include?(name_or_version)
        self.find_by_version(name_or_version)
      else
        # TODO(mtwilliams): Raise an exception.
        # raise VisualStudio::InvalidCriteria.new("Expected a name or version")
      end
    end

    def self.find_by(criteria)
      if criteria.include?(:name)
        self.find_by_name(criteria[:name])
      elsif criteria.include?(:version)
        self.find_by_version(criteria[:version])
      else
        # TODO(mtwilliams): Raise an exception.
        # raise VisualStudio::InvalidCriteria.new("Expected 'name' or 'version' to be specified")
      end
    end

    def self.find_by_name(name)
      if VisualStudio::NAMES.include?(name)
        self.find_by_version(VisualStudio::NAME_TO_VERSION[name])
      else
        # TODO(mtwilliams): Raise an exception.
        # raise VisualStudio::InvalidName.new(...)
      end
    end

    def self.find_by_version(version)
      if VisualStudio::VERSIONS.include?(version)
        # Try to find any products (that we care about) for this version.
        c_and_cpp = VisualStudio::Product.find('VC', version)
        csharp    = VisualStudio::Product.find('VC#', version)

        # If no products (that we care about) for this version are installed,
        # then for all intents and purposes this version of Visual Studio
        # is "not installed". This might not be the truth, but who gives a fuck
        # about Visual Basic anymore?!
        return nil if [c_and_cpp, csharp].all?{|product| product.nil?}

        name = Helpers::PrettyString.new VisualStudio::VERSION_TO_NAME[version],
                                         pretty: VisualStudio::VERSION_TO_PRETTY_NAME[version]

        root = File.expand_path(File.join([c_and_cpp, csharp].compact.first.root, '..'))

        products = {c_and_cpp: c_and_cpp, csharp: csharp}
        products = products.reject{|_, v| v.nil?}

        VisualStudio::Install.new(name: name,
                                  version: version,
                                  root: root,
                                  products: products)
      else
        # TODO(mtwilliams): Raise an exception.
        # raise VisualStudio::InvalidVersion.new(...)
      end
    end
  end
end
