module ImportMap
  struct Entry
    getter specifier : String
    getter url : String
    getter? preload : Bool

    def initialize(@specifier : String, @url : String, @preload : Bool = false)
    end
  end
end
