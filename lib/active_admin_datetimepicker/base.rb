module ActiveAdminDatetimepicker
  module Base
    mattr_accessor :default_datetime_picker_options
    @@default_datetime_picker_options = {}
    mattr_accessor :format, :format_date, :format_time
    @@format = '%Y-%m-%d %H:%M'
    @@format_date = '%Y-%m-%d'
    @@format_time = '%H:%M'

    def html_class
      'date-time-picker'
    end

    def input_html_data
      {}
    end

    def input_html_options(input_name = nil, placeholder = nil)
      super().tap do |options|
        options[:class] = [self.options[:class], html_class].compact.join(' ')
        options[:data] ||= input_html_data
        options[:data].merge!(datepicker_options: datetime_picker_options)
        options[:value] = input_value(input_name)
        options[:maxlength] = 19
        options[:placeholder] = placeholder unless placeholder.nil?
      end
    end

    def input_value(input_name = nil)
      val = object.public_send(input_name || method)
      val.is_a?(Date) ? val.strftime(format_date) : parse_datetime(val)
    end

    def parse_datetime(val)
      DateTime.parse(val.to_s).strftime(format)
    rescue ArgumentError
      nil
    end

    def datetime_picker_options
      @datetime_picker_options ||= begin
        # backport support both :datepicker_options AND :datetime_picker_options
        options = self.options.fetch(:datepicker_options, {})
        options = self.options.fetch(:datetime_picker_options, options)
        options = Hash[options.map { |k, v| [k.to_s.camelcase(:lower), v] }]
        _default_datetime_picker_options.merge(options)
      end
    end

    protected

    def _default_datetime_picker_options
      res = default_datetime_picker_options.map do |k, v|
        if v.respond_to?(:call) || v.is_a?(Proc)
          [k, v.call]
        else
          [k, v]
        end
      end
      Hash[res]
    end

    def format
      datepicker = datetime_picker_options['datepicker']
      timepicker = datetime_picker_options['timepicker']

      if datepicker && !timepicker
        format_date
      elsif !datepicker && timepicker
        format_time
      else
        @@format
      end
    end
  end
end

