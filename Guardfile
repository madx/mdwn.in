# Automatic test runner

guard 'minitest' do
  watch(%r|^spec/(.*)_spec\.rb|)
  watch(%r|^lib/(.*)\.rb|) { |m| "spec/#{m[1]}#{m[2]}_spec.rb" }
  watch(%r|^lib/(.*)\.haml|) { |m| "spec/mdwnin/app_spec.rb" }
end
