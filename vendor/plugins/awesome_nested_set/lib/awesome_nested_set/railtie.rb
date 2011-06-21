# encoding: utf-8
require 'awesome_nested_set'
require 'rails'
require 'rails/plugin'

module CollectiveIdea
  module Acts
    module NestedSet
      class Railtie < ::Rails::Railtie
        initializer "awesome_nested_set.on_rails_init" do
          ActiveSupport.on_load :active_record do
            CollectiveIdea::Acts::NestedSet::Railtie.extend_active_record
          end
          
          ActiveSupport.on_load :action_view do
            ActionView::Base.send(:include, CollectiveIdea::Acts::NestedSet::Helper)
          end
        end
        
        def self.extend_active_record
          ActiveRecord::Base.send :include,
            CollectiveIdea::Acts::NestedSet::Base
        end
      end
    end
  end
end
