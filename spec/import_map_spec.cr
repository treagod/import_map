require "./spec_helper"

ImportMap.draw do
  pin "stimulus", "/js/stimulus.js"

  namespace "admin" do
    pin "sort_controller", "/js/admin/sort_controller.js", preload: false
  end
end

describe ImportMap do
  it "populates manager via DSL" do
    ImportMap::Manager.instance.json("admin").should eq(
      {"imports" => {"stimulus" => "/js/stimulus.js", "sort_controller" => "/js/admin/sort_controller.js"}}.to_json
    )
  end

  it "renders correct HTML tag block" do
    html = ImportMap.tag("admin", "entrypoint")
    html.includes?(%(<link rel="modulepreload" href="/js/stimulus.js">)).should be_true
    html.includes?(%(<link rel="modulepreload" href="/js/admin/sort_controller.js">)).should be_false
    html.includes?(%(<script type="importmap" data-namespace="admin">)).should be_true
    html.includes?(%(<script type="module">import "entrypoint"</script>)).should be_true
    html.includes?(%(<script type="importmap">)).should be_false
  end

  it "resolves paths correctly when setting a custom resolver" do
    ImportMap.resolver = ->(path : String) { "/assets#{path}?v=abc" }
    html = ImportMap.tag("admin", "entrypoint")
    html.includes?(%(<link rel="modulepreload" href="/assets/js/stimulus.js?v=abc">)).should be_true

    ImportMap.resolver = ->(path : String) { path }
  end
end
