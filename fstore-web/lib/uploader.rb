require 'ffi'

module Uploader
  extend FFI::Library
  ffi_lib File.expand_path('native/uploader.so', __dir__)

  attach_function :UploadFile, [:string, :pointer, :int, :string, :string], :string
end
