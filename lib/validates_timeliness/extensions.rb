module ValidatesTimeliness
  module ExtensionLoader
    # makes sure that extensions which reference unloaded modules still work
    # that way it's still possible to use the gem w/o ActiveRecord
    def self.name_error_guard
      begin
        yield
      rescue NameError => e
        warn("Some extension could not be loaded: #{e}")
      end
    end
  end

  module Extensions
    autoload :DateTimeSelect,         'validates_timeliness/extensions/date_time_select'
    ValidatesTimeliness::ExtensionLoader.name_error_guard {
      if ActiveRecord::VERSION::MAJOR < 4
        autoload :MultiparameterHandler, 'validates_timeliness/extensions/multiparameter_handler'
      else
        autoload :AttributeAssignment,     'validates_timeliness/extensions/attribute_assignment'
        autoload :MultiparameterAttribute, 'validates_timeliness/extensions/multiparameter_attribute'
      end
    }
  end

  def self.enable_date_time_select_extension!
    ValidatesTimeliness::ExtensionLoader.name_error_guard {
      if ActiveRecord::VERSION::MAJOR < 4
        ::ActionView::Helpers::InstanceTag.send(:include, ValidatesTimeliness::Extensions::DateTimeSelect)
      else
        ::ActionView::Helpers::Tags::DateSelect.send(:include, ValidatesTimeliness::Extensions::DateTimeSelect)
      end
    }
  end

  def self.enable_multiparameter_extension!
    ValidatesTimeliness::ExtensionLoader.name_error_guard {
      if ActiveRecord::VERSION::MAJOR < 4
        ::ActiveRecord::Base.send(:include, ValidatesTimeliness::Extensions::MultiparameterHandler)
      else
        ::ActiveRecord::Base.send(:include, ValidatesTimeliness::Extensions::AttributeAssignment)
        ::ActiveRecord::AttributeAssignment::MultiparameterAttribute.send(:include, ValidatesTimeliness::Extensions::MultiparameterAttribute)
      end
    }
  end

end
