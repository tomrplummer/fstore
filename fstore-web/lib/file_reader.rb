require 'ffi'

module FileReader
  extend FFI::Library

  ffi_lib File.expand_path('native/file_reader.so', __dir__)

  attach_function :ReadFile, [:string, :pointer], :pointer
end
