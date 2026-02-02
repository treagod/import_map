require "spec"
require "file_utils"
require "random/secure"
require "../src/import_map"

module ImportMap
  class Map
    def entries
      @entries
    end
  end
end

def with_tmpdir(& : String ->)
  base = begin
    Dir.tempdir
  rescue
    "/tmp"
  end

  dir = File.join(base, "import-map-spec-#{Random::Secure.hex(12)}")
  FileUtils.mkdir_p(dir)

  begin
    yield dir
  ensure
    FileUtils.rm_rf(dir)
  end
end
