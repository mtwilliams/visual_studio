module VisualStudio
  module Environment
    SEARCH_DIRECTORIES = ['PATH', 'INCLUDE', 'LIB', 'LIBPATH']

    def self.merge(base, overlay)
      # TODO(mtwilliams): Verify match-up between VCInstallDir and VisualStudioVersion?
      # TODO(mtwilliams): Rederive environment variables based on VCInstallDir and/or WindowsSdkDir.
      env = base.to_h.merge(overlay.to_h) do |variable, base, overlay|
        if SEARCH_DIRECTORIES.include? variable
          # TODO(mtwilliams): Detect new Visual Studio or Windows SDK related
          # paths and replace the old ones based on that.
          base    = base.split(';')
          overlay = overlay.split(';')

          cwd = base.include?('.') || overlay.include?('.')

          # HACK(mtwilliams): We're using File.expand_path here to "normalize"
          # paths to prevent duplicates, but this could very likely have
          # disastrous effects.
          base = base.reject{|p| p=='.'}.map{|p| File.expand_path(p)}
          overlay = overlay.reject{|p| p=='.'}.map{|p| File.expand_path(p)}

          path = base | overlay
          path = ['.'] + path if cwd

          path.join(';')
        else
          # Default to the overlay, or right-hand side.
          overlay
        end
      end
    end
  end
end
