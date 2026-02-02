module ImportMap
  struct MappedDir
    getter dir : String
    getter under : String?
    getter to : String?
    getter? preload : Bool

    def initialize(@dir : String, @under : String?, @to : String?, @preload : Bool)
    end
  end
end
