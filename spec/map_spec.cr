require "./spec_helper"

describe ImportMap::Map do
  it "pins entries and outputs valid JSON" do
    map = ImportMap::Map.new
    map.pin("stimulus", "/js/stimulus.js", preload: false)
    map.pin("turbo", "/js/turbo.js")
    json = map.to_json_string
    json.should eq({"imports" => {"stimulus" => "/js/stimulus.js", "turbo" => "/js/turbo.js"}}.to_json)
  end

  it "pins entries without starting slash and outputs valid JSON" do
    map = ImportMap::Map.new
    map.pin("stimulus", "js/stimulus.js", preload: false)
    map.pin("turbo", "js/turbo.js")
    json = map.to_json_string
    json.should eq({"imports" => {"stimulus" => "js/stimulus.js", "turbo" => "js/turbo.js"}}.to_json)
  end

  it "detects duplicate pins" do
    map = ImportMap::Map.new
    map.pin("stimulus", "/js/stimulus.js")

    expect_raises ImportMap::DuplicatePinError do
      map.pin("stimulus", "/js/another_stimulus.js")
    end
  end

  it "supports override" do
    map = ImportMap::Map.new
    map.pin("stimulus", "/js/stimulus.js")
    map.pin("stimulus", "/js/another_stimulus.js", override: true)
    json = map.to_json_string
    json.should eq({"imports" => {"stimulus" => "/js/another_stimulus.js"}}.to_json)
  end

  it "applies resolver" do
    map = ImportMap::Map.new
    map.pin("stimulus", "/js/stimulus.js")
    map.pin("turbo", "/js/turbo.js")
    resolver = ->(path : String) { "/assets#{path}?v=abc" }
    json = map.to_json_string(resolver)
    json.should eq({"imports" => {"stimulus" => "/assets/js/stimulus.js?v=abc", "turbo" => "/assets/js/turbo.js?v=abc"}}.to_json)
  end

  it "merged keeps self precedence" do
    base = ImportMap::Map.new
    base.pin("stimulus", "/js/stimulus.js")

    admin = ImportMap::Map.new
    admin.pin("sort_controller", "/js/admin/sort_controller.js")
    admin.pin("stimulus", "/js/admin/stimulus.js")

    merged = base.merge(admin)
    merged.entries["stimulus"].url.should eq("/js/stimulus.js")
    merged.entries.has_key?("sort_controller").should be_true
  end
end
