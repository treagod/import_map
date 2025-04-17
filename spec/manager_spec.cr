require "./spec_helper"

describe ImportMap::Manager do
  it "merges base and namespace pins (base only call)" do
    mgr = ImportMap::Manager.new
    mgr.pin("stimulus", "/js/stimulus.js")
    mgr.namespace("admin") do
      pin("sort_controller", "/js/admin/sort_controller.js")
    end

    mgr.json.should eq({"imports" => {"stimulus" => "/js/stimulus.js"}}.to_json)
  end

  it "merges base and namespace pins" do
    mgr = ImportMap::Manager.new
    mgr.pin("stimulus", "/js/stimulus.js")
    mgr.namespace("admin") do
      pin("sort_controller", "/js/admin/sort_controller.js")
    end

    mgr.json("admin").should eq({"imports" => {"stimulus" => "/js/stimulus.js", "sort_controller" => "/js/admin/sort_controller.js"}}.to_json)
  end

  it "raises on unknown namespace" do
    mgr = ImportMap::Manager.new

    expect_raises ImportMap::NamespaceError do
      mgr.json("unknown")
    end
  end

  it "resolves URLs via custom resolver and caches" do
    mgr = ImportMap::Manager.new
    mgr.pin("stimulus", "/js/stimulus.js")
    mgr.pin("turbo", "/js/turbo.js")

    resolver = ->(path : String) { "/assets#{path}?v=abc" }
    mgr.resolver = resolver

    mgr.json.should eq({"imports" => {"stimulus" => "/assets/js/stimulus.js?v=abc", "turbo" => "/assets/js/turbo.js?v=abc"}}.to_json)
    mgr.preloads.empty?.should be_false
  end

  it "return an empty preloads array when all pins have preload=false" do
    mgr = ImportMap::Manager.new
    mgr.pin("stimulus", "/js/stimulus.js", preload: false)
    mgr.pin("turbo", "/js/turbo.js", preload: false)

    mgr.namespace("admin") do
      pin("sort_controller", "/js/admin/sort_controller.js", preload: false)
    end

    mgr.preloads.empty?.should be_true
    mgr.preloads("admin").empty?.should be_true
  end
end
