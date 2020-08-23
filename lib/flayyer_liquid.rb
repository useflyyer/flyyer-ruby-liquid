require 'flayyer_liquid/version'
require 'flayyer'
require 'liquid'

module FlayyerLiquid
  class Error < StandardError; end

  class FlayyerTag < Liquid::Tag
    attr_accessor :params
    attr_accessor :version, :tenant, :deck, :template, :extension, :variables

    def initialize(tag_name, params, tokens)
      super
      @params = params
    end

    def render(context)
      @variables = {}
      @version = '_' # latest
      @extension = 'jpeg'

      # Pre-render values enclosed in {{ }}
      params = Liquid::Template.parse(@params).render(context)

      # TODO: Since 2015 there is no official way of passing multiple args
      params.scan(Liquid::TagAttributes) do |key, value|
        value = value.gsub(/^'|"/, '').gsub(/'|"$/, '')
        case key
        when 'tenant'
          @tenant = value
        when 'deck'
          @deck = value
        when 'template'
          @template = value
        when 'version'
          @version = value
        when 'extension'
          @extension = value
        else
          @variables[key] = value
        end
      end

      flayyer = Flayyer::FlayyerURL.create do |f|
        f.tenant = context['flayyer_tenant'].nil? || context['flayyer_tenant'].empty? ? @tenant : context['flayyer_tenant']
        f.deck = context['flayyer_deck'].nil? || context['flayyer_deck'].empty? ? @deck : context['flayyer_deck']
        f.template = context['flayyer_template'].nil? || context['flayyer_template'].empty? ? @template : context['flayyer_template']
        f.variables = context['flayyer_variables'].nil? || context['flayyer_variables'].empty? ? @variables : context['flayyer_variables']
        f.version = context['flayyer_version'].nil? || context['flayyer_version'].empty? ? @version : context['flayyer_version']
        f.extension = context['flayyer_extension'].nil? || context['flayyer_extension'].empty? ? @extension : context['flayyer_extension']
      end

      begin
        return flayyer.href
      rescue Flayyer::Error # missing tenant, deck or template
        return ''
      end
    end
  end
end
