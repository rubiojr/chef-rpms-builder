#!/usr/bin/env ruby
#
# Pre-requisites:
#
# git needs to be installed
# pkg-wizard build-bot needs to be running
#
# yum install rpmdevtools 
# gem install pkg-wizard
# gem install merb-core merb-slices merb-assets merb-helpers merb-haml moneta bunny uuidtools
# gem install rspec rake cucumber jeweler gemcutter
#
# See:
# http://wiki.opscode.com/display/chef/Installing+Chef+from+HEAD
#
require 'rubygems'
require 'pkg-wizard/rpm'
require 'fileutils'
require 'logger'

Log = Logger.new('build-master.log')
$log = Log
BUILD_BOT_URL = "http://el5-builder:4567"
BASE_DIR = Dir.pwd
PKG_SRC_DIR = File.join(BASE_DIR, 'packages')
GEM_SRC_DIR = File.join(BASE_DIR, 'packages/sources')
CHEF_SRC_DIR = File.join(BASE_DIR, 'chef') 
CHEF_MODULES = %w{chef chef-server chef-server-api chef-server-webui chef-solr chef-expander}
SRC_RPMS_GIT_URLS = %w{
  git@github.com:frameos/rubygem-chef-server-rpm.git
  git@github.com:frameos/rubygem-chef-server-webui-rpm.git
  git@github.com:frameos/rubygem-chef-server-api-rpm.git
  git@github.com:frameos/rubygem-chef-rpm.git
  git@github.com:frameos/rubygem-chef-solr-rpm.git
  git@github.com:frameos/rubygem-chef-expander-rpm.git
}

def debug(msg)
  puts "DEBUG: #{msg}" if not ARGV.include? '--quiet'
  $log.debug msg
end
def info(msg)
  puts "INFO: #{msg}"
  $log.info msg
end
def error(msg)
  puts "ERROR: #{msg}"
  $log.error msg
end

info "-----------------------------------------------"
info "#{Time.now.to_s} BUILDING CHEF MASTER"
info "-----------------------------------------------"

#
# Check if git command is available
#
if `which git`.strip.chomp.empty?
  error "git command not found. Aborting"
  exit 1
end

if not File.directory? File.join(CHEF_SRC_DIR, ".git")
  msg = "Chef source directory not found. Do you want to check it out? "
  puts msg
  if $stdin.gets =~ /^(y|Y)/
    debug `git clone https://github.com/opscode/chef.git 2>1`
  else
    error "Chef source dir not found."
    exit 1
  end
end

FileUtils.mkdir_p GEM_SRC_DIR

#
# Clean previously generated gems
#

Dir.chdir CHEF_SRC_DIR

debug `git reset --hard`
debug `git pull`

#
# Build chef rubygems
#
packages = CHEF_MODULES
packages.each do |p|
  old_dir = Dir.pwd
  begin
    info "Building #{p} gem..."
    Dir.chdir p
    debug `rake package 2>1`
    gem = Dir["pkg/*.gem"].first
    FileUtils.cp gem, GEM_SRC_DIR
  rescue Exception => e
    error "Error building #{p}: #{e.message}"
  ensure
    Dir.chdir old_dir
  end
end

Dir.chdir BASE_DIR 

#
# Create source RPMS
# 
packages.each do |p|
  src = File.join(PKG_SRC_DIR, "#{p}")
  if File.exist?("rubygem-#{p}-rpm/.git")
    # package sources already checked out, clean them
    info "Cleaning #{p} RPM sources"
    Dir.chdir src
    `git reset --hard`
    Dir.chdir BASE_DIR
  else
    Dir.chdir PKG_SRC_DIR
    url = SRC_RPMS_GIT_URLS.find { |u| u =~ /rubygem-#{p}-rpm/ }
    info "Fetching #{p} RPM sources"
    debug `git clone #{url} 2>1`
    Dir.chdir BASE_DIR
  end
end

# 
# Copy gem to package source dir
#
Dir["#{GEM_SRC_DIR}/*.gem"].each do |g|
  gem_name = File.basename(g, '.gem').split('-')[0..-2].join('-')
  info "Updating #{gem_name} RPM sources"
  FileUtils.cp g, "#{PKG_SRC_DIR}/rubygem-#{gem_name}-rpm/"
end

# 
# Build SRPM
#
debug `rpmdev-setuptree 2>1`
debug `rpmdev-wipetree 2>1`
Dir["#{PKG_SRC_DIR}/*"].each do |d|
  next if d =~ /sources/ or not File.directory?(d)
  Dir.chdir d
  info "Creating #{d.split('/').last} SRPM"
  PKGWizard::SRPM.create
  Dir.chdir BASE_DIR
end

Dir.chdir BASE_DIR

info "SRPM packages available at #{ENV['HOME']}/rpmbuild/SRPMS"
