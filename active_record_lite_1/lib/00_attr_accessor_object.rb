class AttrAccessorObject
  def self.my_attr_accessor(*names)
    # ...
    names.each do |attribute|
      heredoc = <<-MAGIC_STRING
        def #{attribute}
          @#{attribute}
        end

        def #{attribute}=(value)
          @#{attribute} = value
        end
      MAGIC_STRING
      class_eval(heredoc)
    end
  end
end
