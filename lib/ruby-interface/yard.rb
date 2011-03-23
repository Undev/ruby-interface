class RubyInterfaceHandler < YARD::Handlers::Ruby::Base
  handles method_call(:interface)
  
  def process
    parse_block(statement.last.last)
  rescue YARD::Handlers::NamespaceMissingError
  end
end