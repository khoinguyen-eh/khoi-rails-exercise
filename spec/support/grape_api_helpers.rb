# frozen_string_literal: true

module GrapeApiHelpers
  %i[post patch put].each do |method_name|
    define_method(method_name) do |path, args = {}|
      default_options = { as: :json }
      process method_name, path, **default_options.merge(args)
    end
  end
end
