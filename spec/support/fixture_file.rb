require 'fileutils'

FIXTURE_DIR = File.join(File.dirname(__FILE__), '..', 'fixtures')
TMP_DIR = File.join(File.dirname(__FILE__), '..', 'tmp')

def fixture_file(filename)
  FileUtils.mkdir_p(TMP_DIR)
  FileUtils.cp(File.join(FIXTURE_DIR, filename), File.join(TMP_DIR, filename))
  File.new(File.join(TMP_DIR, filename))
end
