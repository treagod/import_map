module ImportMap
  class Map
    @entries : Hash(String, Entry) = {} of String => Entry

    protected def entries
      @entries
    end

    # Adds a new pin. Raises `DuplicatePinError` if the specifier already exists and `override` is not set to true.
    def pin(specifier : String, url : String, preload : Bool = false, override : Bool = false)
      if @entries.has_key?(specifier) && !override
        raise DuplicatePinError.new("Specifier #{specifier} already pinned")
      end
      @entries[specifier] = Entry.new(specifier, url, preload)
    end

    def to_json_string(resolver : Proc(String, String)? = nil) : String
      String.build do |io|
        JSON.build(io) do |json|
          json.object do
            json.field "imports" do
              json.object do
                @entries.each do |specifier, entry|
                  json.field specifier do
                    url = entry.url.starts_with?("/") && resolver ? resolver.call(entry.url) : entry.url
                    json.string url
                  end
                end
              end
            end
          end
        end
      end
    end

    def preload_urls(resolver : Proc(String, String)? = nil) : Array(String)
      url = Array(String).new(@entries.size)
      @entries.each_value do |entry|
        next unless entry.preload

        url = entry.url.starts_with?("/") && resolver ? resolver.call(entry.url) : entry.url
        url << url
      end
      urls
    end

    def merge(other : Map) : Map
      merged = Map.new

      @entries.each do |specifier, entry|
        merged.entries[specifier] = entry
      end
      other.entries.each do |specifier, entry|
        merged.entries[specifier] = entry unless merged.entries.has_key?(specifier)
      end

      merged
    end
  end
end
