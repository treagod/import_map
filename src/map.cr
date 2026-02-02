module ImportMap
  class Map
    URI_SCHEME_REGEX = /\A[a-z][a-z0-9+\-.]*:\/\//i

    @entries : Hash(String, Entry) = {} of String => Entry

    protected def entries
      @entries
    end

    # Adds a new pin. Raises `DuplicatePinError` if the specifier already exists and `override` is not set to true.
    def pin(specifier : String, url : String, preload : Bool = true, override : Bool = false)
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
                    url = resolver && needs_resolve?(entry.url) ? resolver.call(entry.url) : entry.url
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
      urls = Array(String).new(@entries.size)
      @entries.each_value do |entry|
        next unless entry.preload?

        url = resolver && needs_resolve?(entry.url) ? resolver.call(entry.url) : entry.url
        urls << url
      end
      urls
    end

    def merge(other : Map) : Map
      merged = Map.new

      @entries.each do |specifier, entry|
        merged.entries[specifier] = entry
      end
      other.entries.each do |specifier, entry|
        merged.entries[specifier] = entry
      end

      merged
    end

    private def needs_resolve?(url : String) : Bool
      !URI_SCHEME_REGEX.matches?(url)
    end
  end
end
