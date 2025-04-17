require "json"
require "./**"

module ImportMap
  VERSION = "0.1.0"

  def self.draw(&)
    with ImportMap::Manager.instance yield
  end

  def self.resolver=(resolver : Proc(String, String))
    ImportMap::Manager.instance.resolver = resolver
  end

  def self.tag(ns : String? = nil, entrypoint : String? = nil)
    m = Manager.instance

    json = m.json(ns)
    preloads = m.preloads(ns)

    String.build do |io|
      preloads.each do |url|
        io << %(<link rel="modulepreload" href="#{url}">\n)
      end
      data = ns ? %( data-namespace="#{ns}") : ""
      io << %(<script type="importmap"#{data}>#{json}</script>\n)
      if entrypoint
        io << %(<script type="module">import #{entrypoint}</script>\n)
      end
    end
  end
end
