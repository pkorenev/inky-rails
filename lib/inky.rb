require "action_view"
require "action_view/template"
require "inky/inky_template"
require "inky/railtie"
require "rubygems"

module Inky

  def self.check_version(bin)
    begin
      # TODO: Extract inky-cli version to an explicit constant
      Gem::Dependency.new('','~> 1.0.1').match?('',`#{bin} --version`)
    rescue
      false
    end
  end

  def self.discover_inky_bin
    default_bin_name = 'inky'
    inky_bin = default_bin_name
    # Check for a global install of Inky binary
    return inky_bin if check_version(default_bin_name)

    # Check for a local install of Inky binary
    inky_bin = File.join(`npm bin`.chomp, default_bin_name)
    return inky_bin if check_version(inky_bin)

    raise RuntimeError, "Couldn't find the Inky binary.. have you run $ npm install #{default_bin_name}?"
  end

  BIN = discover_inky_bin

  class Handler
    def erb_handler
      @erb_handler ||= ActionView::Template.registered_template_handler(:erb)
    end
    
    def slim_handler
      @slim_handler ||= ActionView::Template.registered_template_handler(:slim)
    end  

    def call(template, format = :slim)
      compiled_source = send("#{format}_handler").call(template)
      if template.formats.include?(:inky)
        "Inky::InkyTemplate.to_html(begin;#{compiled_source};end).html_safe"
      else
        compiled_source
      end
    end
  end
end
