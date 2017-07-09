module VisualStudio
  module Environment
    SEARCH_DIRECTORIES = ['PATH', 'INCLUDE', 'LIB', 'LIBPATH']

    def self.merge(base, overlay)
      # We merge case insensitively, because Windows. We treat |base| case as canonical
      # unless the variable is only named by |overlay|.
      cased = (overlay.keys + base.keys).uniq.map{|key| [key.upcase, key]}.to_h

      # TODO(mtwilliams): Verify match-up between VCInstallDir and VisualStudioVersion?
      # TODO(mtwilliams): Rederive environment variables based on VCInstallDir and/or WindowsSdkDir.
      env = canonicalize(base).merge(canonicalize(overlay)) do |variable, base, overlay|
        if SEARCH_DIRECTORIES.include? variable.upcase
          # TODO(mtwilliams): Detect new Visual Studio or Windows SDK related
          # paths and replace the old ones based on that.
          base    = base.split(';')
          overlay = overlay.split(';')

          should_include_cwd = base.include?('.') || overlay.include?('.')

          # HACK(mtwilliams): We're using File.expand_path here to "normalize"
          # paths to prevent duplicates, but this could very likely have
          # disastrous effects.
          base = base.reject{|p| p=='.'}.map{|p| File.expand_path(p)}
          overlay = overlay.reject{|p| p=='.'}.map{|p| File.expand_path(p)}

          path = base | overlay
          path = ['.'] + path if should_include_cwd

          path.join(';')
        else
          # Right-hand side takes precedence.
          overlay
        end
      end

      env.map { |canonical, value|
        [cased[canonical], value]
      }.to_h
    end

    private
      def self.canonicalize(environment)
        environment.to_h.map{|key, value| [key.upcase, value]}.to_h
      end
  end
end
