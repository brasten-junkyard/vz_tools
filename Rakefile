#  @author Brasten Lee Sager <brasten@nagilum.com>
#  @see LICENSE.md

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'
require 'spec/rake/spectask'

namespace :spec do
  desc "Run all examples with RCov"
  Spec::Rake::SpecTask.new('rcov') do |t|
    t.spec_files = FileList['spec/**/*_spec.rb']
    t.rcov = true
#    t.rcov_opts = ['--exclude', 'spec']
  end
end


# Documentation
namespace :doc do

  # Generate rdoc
  Rake::RDocTask.new do |rd|
    rd.main = "README"
    rd.rdoc_files.include("README", "lib/**/*.rb")
    rd.rdoc_dir = "doc/html"
  end
end
